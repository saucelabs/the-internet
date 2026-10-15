require_relative 'spec_helper'
require 'digest'
require 'securerandom'

REPO_ROOT = File.expand_path('../..', __dir__)

describe 'Behaviour' do
  def flash(res)
    html(res).at_css('#flash-messages #flash')
  end

  describe 'Basic auth' do
    %w[/basic_auth /basic_auth/ /download_secure].each do |path|
      it "#{path} challenges without credentials" do
        res = client.get(path)
        expect(res.code).to eq '401'
        expect(res['www-authenticate']).to eq 'Basic realm="Restricted Area"'
      end

      it "#{path} rejects wrong credentials" do
        req = Net::HTTP::Get.new(path).tap { |r| r.basic_auth('admin', 'nope') }
        expect(client.request(req).code).to eq '401'
      end

      it "#{path} accepts admin/admin" do
        req = Net::HTTP::Get.new(path).tap { |r| r.basic_auth('admin', 'admin') }
        expect(client.request(req).code).to eq '200'
      end
    end

    it 'shows the success message' do
      req = Net::HTTP::Get.new('/basic_auth').tap { |r| r.basic_auth('admin', 'admin') }
      expect(client.request(req).body).to include 'Congratulations! You must have the proper credentials.'
    end

    it 'serves secure downloads with credentials' do
      req = Net::HTTP::Get.new('/download_secure/some-file.txt').tap { |r| r.basic_auth('admin', 'admin') }
      expect(client.request(req).code).to eq '200'
    end
  end

  describe 'Digest auth' do
    def challenge(path)
      res = client.get(path)
      expect(res.code).to eq '401'
      res['www-authenticate']
    end

    def digest_get(path, user, pass)
      header = challenge(path)
      params = header.delete_prefix('Digest ').scan(/(\w+)="([^"]*)"/).to_h
      cnonce = SecureRandom.hex(8)
      ha1 = Digest::MD5.hexdigest("#{user}:#{params['realm']}:#{pass}")
      ha2 = Digest::MD5.hexdigest("GET:#{path}")
      response = Digest::MD5.hexdigest("#{ha1}:#{params['nonce']}:00000001:#{cnonce}:auth:#{ha2}")
      auth = %(Digest username="#{user}", realm="#{params['realm']}", nonce="#{params['nonce']}", ) +
             %(uri="#{path}", qop=auth, nc=00000001, cnonce="#{cnonce}", response="#{response}", ) +
             %(opaque="#{params['opaque']}")
      client.get(path, 'Authorization' => auth)
    end

    it 'challenges with realm "Protected Area" and qop=auth' do
      header = challenge('/digest_auth')
      expect(header).to start_with 'Digest '
      expect(header).to include 'realm="Protected Area"', 'qop="auth"', 'nonce="', 'opaque="'
    end

    %w[/digest_auth /digest_auth/].each do |path|
      it "#{path} accepts admin/admin" do
        res = digest_get(path, 'admin', 'admin')
        expect(res.code).to eq '200'
        expect(res.body).to include 'Digest Auth', 'Congratulations! You must have the proper credentials.'
      end
    end

    it 'rejects a wrong password' do
      expect(digest_get('/digest_auth', 'admin', 'nope').code).to eq '401'
    end
  end

  describe 'Form authentication' do
    def login(username, password)
      client.post('/authenticate', username: username, password: password)
    end

    it 'rejects an unknown username' do
      res = login('nobody', 'SuperSecretPassword!')
      # Sinatra answers redirects to non-GET requests with 303 See Other.
      expect(res.code).to eq '303'
      expect(path_of(res['location'])).to eq '/login'
      el = flash(client.follow(res))
      expect(el['class'].split).to include 'flash', 'error'
      expect(el.text).to include 'Your username is invalid!'
    end

    it 'rejects a wrong password' do
      res = login('tomsmith', 'nope')
      expect(flash(client.follow(res)).text).to include 'Your password is invalid!'
    end

    it 'logs in, shows the secure area and logs out' do
      res = login('tomsmith', 'SuperSecretPassword!')
      expect(res.code).to eq '303'
      expect(path_of(res['location'])).to eq '/secure'

      secure = client.follow(res)
      expect(secure.code).to eq '200'
      el = flash(secure)
      expect(el['class'].split).to include 'flash', 'success'
      expect(el.text).to include 'You logged into a secure area!'
      expect(secure.body).to include 'Secure Area', 'href="/logout"'

      out = client.get('/logout')
      expect(path_of(out['location'])).to eq '/login'
      expect(flash(client.follow(out)).text).to include 'You logged out of the secure area!'

      again = client.get('/secure')
      expect(path_of(again['location'])).to eq '/login'
    end

    it 'redirects anonymous visitors away from /secure' do
      res = client.get('/secure')
      expect(res.code).to eq '302'
      expect(flash(client.follow(res)).text).to include 'You must login to view the secure area!'
    end
  end

  describe 'Notification messages' do
    it 'redirects and shows one of the two notices' do
      res = client.get('/notification_message')
      expect(res.code).to eq '302'
      expect(path_of(res['location'])).to eq '/notification_message_rendered'
      el = flash(client.follow(res))
      expect(el['class'].split).to include 'flash', 'notice'
      expect(['Action successful', 'Action unsuccesful, please try again']).to include el.children.first.text.strip
    end
  end

  describe 'Status codes' do
    %w[200 301 404 500].each do |code|
      it "/status_codes/#{code} returns #{code}" do
        res = client.get("/status_codes/#{code}")
        expect(res.code).to eq code
        expect(res.body).to include "This page returned a #{code} status code."
      end
    end

    it '/redirect redirects to /status_codes' do
      res = client.get('/redirect')
      expect(res.code).to eq '302'
      expect(path_of(res['location'])).to eq '/status_codes'
    end

    it 'unknown paths return 404' do
      expect(client.get('/this-page-does-not-exist').code).to eq '404'
    end
  end

  describe 'Downloads' do
    it 'lists the seeded file' do
      links = html(client.get('/download')).css('#content a').map { |a| a['href'] }
      expect(links).to include 'download/some-file.txt'
    end

    it 'serves the seeded file as an attachment' do
      res = client.get('/download/some-file.txt')
      expect(res.code).to eq '200'
      expect(res['content-disposition']).to include 'attachment', 'some-file.txt'
      # On live, visitors can overwrite the seeded file through /upload.
      next unless LOCAL

      expect(res.body.b).to eq File.binread(File.join(REPO_ROOT, 'public/uploads/some-file.txt'))
    end
  end

  describe 'Uploads', :writes do
    let(:name) { "contract-#{SecureRandom.hex(4)}.txt" }
    after { File.delete(File.join(REPO_ROOT, 'public/uploads', name)) if LOCAL && File.exist?(File.join(REPO_ROOT, 'public/uploads', name)) }

    it 'accepts a multipart upload and lists it for download' do
      res = client.post_multipart('/upload', [['file', StringIO.new('hello'), { filename: name, content_type: 'text/plain' }]])
      expect(res.code).to eq '200'
      expect(html(res).at_css('#uploaded-files').text.strip).to eq name
      expect(client.get("/download/#{name}").body).to eq 'hello'
    end

    it 'does not let uploads overwrite the seeded file' do
      seeded = File.binread(File.join(REPO_ROOT, 'public/uploads/some-file.txt'))
      res = client.post_multipart('/upload', [['file', StringIO.new('overwritten'), { filename: 'some-file.txt', content_type: 'text/plain' }]])
      expect(res.code).to eq '200'
      expect(client.get('/download/some-file.txt').body.b).to eq seeded
    end
  end

  describe 'Forgot password', :writes do
    it 'redirects to /email_sent' do
      res = client.post('/forgot_password', email: 'contract-test@example.com')
      expect(res.code).to eq '303'
      expect(path_of(res['location'])).to eq '/email_sent'
    end

    it 'redirects to /email_sent even for an invalid address' do
      res = client.post('/forgot_password', email: 'not-an-email')
      expect(res.code).to eq '303'
      expect(path_of(res['location'])).to eq '/email_sent'
    end
  end

  describe 'Entry ad' do
    it 'accepts the dismiss toggle' do
      expect(client.post('/entry_ad').code).to eq '200'
    end
  end

  describe 'Parameterised examples' do
    it '/add_remove_elements/:n renders n Delete buttons' do
      buttons = html(client.get('/add_remove_elements/3')).css('#elements button')
      expect(buttons.map(&:text)).to eq ['Delete'] * 3
    end

    it '/large/:n nests n levels' do
      res = client.get('/large/3')
      expect(res.body).to include 'These examples are nested 3 levels deep.'
      expect(html(res).css('#large-table thead th').size).to eq 3
    end

    it '/infinite_scroll/:n links to the next page' do
      expect(client.get('/infinite_scroll/4').body).to include "href='/infinite_scroll/5'"
    end

    it '/dynamic_content?with_content=static keeps the first two avatars fixed' do
      srcs = 2.times.map { html(client.get('/dynamic_content?with_content=static')).css('#content img').first(2).map { |i| i['src'] } }
      expect(srcs.uniq.size).to eq 1
    end
  end

  describe 'Shifting content' do
    def shift(res)
      res.body[/left: -(\d+)px/, 1].to_i
    end

    it 'alternates 0 and 25 pixels per visit (cookie)' do
      expect(3.times.map { shift(client.get('/shifting_content/menu')) }).to eq [0, 25, 0]
    end

    it 'honours ?pixel_shift' do
      client.get('/shifting_content/menu?pixel_shift=100')
      expect(shift(client.get('/shifting_content/menu?pixel_shift=100'))).to eq 100
    end

    it '/shifting_content/list shows the five items' do
      body = client.get('/shifting_content/list').body
      expect(body).to include "Important Information You're Looking For", 'Et numquam et aliquam.'
    end
  end

  describe 'Random examples stay within their variants' do
    it '/disappearing_elements shows 4 or 5 menu items' do
      count = html(client.get('/disappearing_elements')).css('#content ul li').size
      expect([4, 5]).to include count
    end

    it '/typos shows one of the two sentences' do
      body = client.get('/typos').body
      expect(body.include?("Sometimes you'll see a typo, other times you won't.") ||
             body.include?("Sometimes you'll see a typo, other times you won,t.")).to be true
    end

    it '/challenging_dom has three buttons with UUID ids' do
      buttons = html(client.get('/challenging_dom')).css('#content a.button')
      expect(buttons.size).to eq 3
      buttons.each { |b| expect(b['id']).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/) }
    end
  end
end
