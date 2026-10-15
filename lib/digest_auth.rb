require 'digest/md5'
require 'rack/utils'

# HTTP Digest authentication (RFC 2617, MD5, qop=auth) as a Rack middleware.
#
# Rack 3 removed Rack::Auth::Digest; this is a compact port of the Rack 2.2
# implementation (MIT licensed) so /digest_auth keeps behaving exactly the same:
# same challenge header, same 401/400 responses.
class DigestAuth
  QOP = 'auth'.freeze

  def initialize(app, realm:, opaque:, private_key:, &authenticator)
    @app = app
    @realm = realm
    @opaque = md5(opaque)
    @private_key = private_key
    @authenticator = authenticator
  end

  def call(env)
    header = env['HTTP_AUTHORIZATION'].to_s
    return unauthorized if header.empty?

    scheme, raw = header.split(' ', 2)
    params = parse(raw.to_s)
    request = Rack::Request.new(env)
    unless scheme.to_s.downcase == 'digest' && request.fullpath == params['uri'] && params['qop'] == QOP
      return bad_request
    end

    return unauthorized unless valid?(params, request.request_method)

    env['REMOTE_USER'] = params['username']
    @app.call(env)
  end

  private

  def valid?(params, method)
    return false unless params['opaque'] == @opaque && valid_nonce?(params['nonce'].to_s)

    password = @authenticator.call(params['username'])
    return false unless password

    ha1 = md5("#{params['username']}:#{params['realm']}:#{password}")
    ha2 = md5("#{method}:#{params['uri']}")
    expected = md5("#{ha1}:#{params['nonce']}:#{params['nc']}:#{params['cnonce']}:#{QOP}:#{ha2}")
    Rack::Utils.secure_compare(expected, params['response'].to_s)
  end

  def nonce
    timestamp = Time.now.to_i
    ["#{timestamp} #{nonce_digest(timestamp)}"].pack('m').strip
  end

  def valid_nonce?(value)
    timestamp, digest = value.unpack1('m').to_s.split(' ', 2)
    !digest.nil? && nonce_digest(timestamp) == digest
  end

  def nonce_digest(timestamp)
    md5("#{timestamp}:#{@private_key}")
  end

  def challenge
    %(Digest realm="#{@realm}", nonce="#{nonce}", opaque="#{@opaque}", qop="#{QOP}")
  end

  def parse(str)
    str.scan(/\w+=(?:"[^"]+"|[^,]+)/).to_h do |pair|
      key, value = pair.split('=', 2)
      value = Regexp.last_match(1) if value =~ /\A"(.*)"\z/
      [key, value.gsub(/\\(.)/, '\1')]
    end
  end

  def unauthorized
    [401, { 'content-type' => 'text/plain', 'content-length' => '0', 'www-authenticate' => challenge }, []]
  end

  def bad_request
    [400, { 'content-type' => 'text/plain', 'content-length' => '0' }, []]
  end

  def md5(data)
    Digest::MD5.hexdigest(data)
  end
end
