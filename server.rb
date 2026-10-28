require 'bundler/setup'
require 'securerandom'
require 'uri'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/cookies'
require 'faker'
require_relative 'lib/digest_auth'

# Shared by every process (puma workers) so sessions and digest nonces
# issued by one worker are accepted by the others.
SESSION_SECRET = ENV.fetch('SESSION_SECRET') { SecureRandom.hex(64) }

class Protected < Sinatra::Base
  register Sinatra::Flash

  get '/' do
    erb :digest_auth
  end

  def self.new(*)
    DigestAuth.new(super, realm: 'Protected Area', opaque: 'secretkey', private_key: SESSION_SECRET) do |username|
      {'admin' => 'admin'}[username]
    end
  end
end

class Public < Sinatra::Base
  helpers Sinatra::Cookies
  set :cookie_options, :domain => nil
  enable :sessions, :logging
  set :session_secret, SESSION_SECRET
  register Sinatra::Flash

  get '/' do
    erb :index
  end

  get '/upload' do
    erb :upload
  end

  # Files shipped with the app; uploads may not overwrite them.
  SEEDED_UPLOADS = Dir.children('public/uploads').freeze

  # Uploads are listed publicly on /download, so keep out programs and big files.
  BLOCKED_UPLOAD_EXTENSIONS = %w[.apk .app .bat .cmd .com .cpl .dll .dmg .exe .hta .jar .js .lnk .msi .ps1 .scr .sh .vbs .wsf].freeze
  MAX_UPLOAD_BYTES = 2 * 1024 * 1024

  # Keeps letters, digits, dot, dash and underscore; everything else becomes "_".
  def self.clean_upload_name(name)
    File.basename(name.to_s).gsub(/[^A-Za-z0-9._-]/, '_')
  end

  post '/upload' do
    file = params['file']
    # No file chosen: still a 500 (as it always was), but with an explanation.
    unless file.is_a?(Hash) && file[:tempfile]
      halt 500, erb(:upload_error, locals: { title: 'Internal Server Error', message: 'No file was chosen. Please choose a file to upload.' })
    end
    filename = self.class.clean_upload_name(file[:filename])
    unless filename.match?(/[A-Za-z0-9]/)
      halt 422, erb(:upload_error, locals: { title: 'File name not allowed', message: 'The file name needs at least one letter or digit.' })
    end
    extension = File.extname(filename).downcase
    if BLOCKED_UPLOAD_EXTENSIONS.include?(extension)
      halt 422, erb(:upload_error, locals: { title: 'File type not allowed', message: "#{extension} files can't be uploaded." })
    end
    if file[:tempfile].size > MAX_UPLOAD_BYTES
      halt 413, erb(:upload_error, locals: { title: 'File too large', message: 'Files can be up to 2 MB.' })
    end
    unless SEEDED_UPLOADS.include?(filename)
      File.open(File.join('public/uploads', filename), 'wb') do |f|
        f.write(file[:tempfile].read)
      end
    end
    erb :uploaded, locals: { file: file }
  end

  get '/download' do
    @file_list = Dir.glob("public/uploads/*.*").map { |f| f.split('/').last }
    erb :download
  end

  get '/download/:filename' do |filename|
    mime_type = get_mime_type_for(filename)

    send_file "public/uploads/#{File.basename(filename)}",
      :filename => filename,
      :type => mime_type
  end

  get '/download/jqueryui/menu/:filename' do |filename|
    mime_type = get_mime_type_for(filename)

    send_file "public/uploads/jqueryui/menu/#{filename}",
      :filename => filename,
      :type => mime_type
  end

  get '/download_secure' do
    protected!
    @file_list = Dir.glob("public/uploads/*.*").map { |f| f.split('/').last }
    erb :download_secure
  end

  get '/download_secure/:filename' do |filename|
    protected!
    mime_type = get_mime_type_for(filename)

    send_file "public/uploads/#{File.basename(filename)}",
      :filename => filename,
      :type => mime_type
  end

  get '/horizontal_slider' do
    erb :horizontal_slider
  end

  def get_mime_type_for(filename)
    file_type = filename.split('.').last
    case file_type
      when 'csv'
        'text/csv'
      when 'jpg'
        'image/jpeg'
      when 'pdf'
        'application/pdf'
      when 'xls'
        'application/vnd.ms-excel'
      else
        'application/octet-stream'
    end
  end

  get '/frame_top' do
    erb :frame_top, :layout => false
  end

  get '/frame_bottom' do
    erb :frame_bottom, :layout => false
  end

  get '/frame_left' do
    erb :frame_left, :layout => false
  end

  get '/frame_right' do
    erb :frame_right, :layout => false
  end

  get '/frame_middle' do
    erb :frame_middle, :layout => false
  end

  get '/nested_frames' do
    erb :nested_frames, :layout => false
  end

  get '/frames' do
    erb :frames
  end

  get '/iframe' do
    erb :tinymce
  end

  get '/tinymce' do
    erb :tinymce
  end

  get '/jqueryui/menu' do
    erb :jqueryui_menu
  end

  get '/jqueryui' do
    erb :jqueryui
  end

  get '/windows' do
    erb :windows
  end

  get '/windows/new' do
    erb :new_window, layout: false
  end

  get '/dropdown' do
    erb :dropdown
  end

  get '/multiple_dropdown' do
    erb :multiple_dropdown
  end

  get '/radio_buttons' do
    erb :radio_buttons
  end

  get '/readonly' do
    erb :readonly
  end

  get '/canvas' do
    erb :canvas
  end

  get '/large_form' do
    erb :large_form
  end

  post '/large_form' do
    fields = params.to_h.transform_values { |value| Array(value).join(', ') }
    fields['password'] = '*' * fields['password'].length if fields['password']
    erb :large_form_result, locals: { fields: fields }
  end

  TWO_FACTOR_CODE_TTL = 180

  get '/two_factor' do
    erb :two_factor
  end

  post '/two_factor/authenticate' do
    if params[:username] == 'tomsmith' && params[:password] == 'SuperSecretPassword!'
      session[:two_factor] = { 'code' => format('%06d', SecureRandom.random_number(1_000_000)), 'expires_at' => Time.now.to_i + TWO_FACTOR_CODE_TTL }
      redirect '/two_factor/code'
    else
      flash[:error] = 'Your username or password is invalid!'
      redirect '/two_factor'
    end
  end

  get '/two_factor/code' do
    redirect '/two_factor' unless session[:two_factor]
    erb :two_factor_code, locals: { code: session[:two_factor]['code'] }
  end

  post '/two_factor/verify' do
    pending = session[:two_factor]
    redirect '/two_factor' unless pending
    if Time.now.to_i > pending['expires_at']
      session[:two_factor] = nil
      flash[:error] = 'Your code has expired! Please log in again.'
      redirect '/two_factor'
    elsif Rack::Utils.secure_compare(params[:code].to_s, pending['code'])
      session[:two_factor] = nil
      session[:two_factor_user] = 'tomsmith'
      flash[:success] = 'You logged in with two-factor authentication!'
      redirect '/two_factor/secure'
    else
      flash[:error] = 'Your code is invalid!'
      redirect '/two_factor/code'
    end
  end

  get '/two_factor/secure' do
    unless session[:two_factor_user]
      flash[:error] = 'You must log in to view the secure area!'
      redirect '/two_factor'
    end
    erb :two_factor_secure
  end

  get '/two_factor/logout' do
    session[:two_factor_user] = nil
    flash[:success] = 'You logged out of the secure area!'
    redirect '/two_factor'
  end

  get '/shadowdom' do
    erb :shadowdom
  end

  def random_notification_message
    messages = [
      'Action successful',
      'Action unsuccesful, please try again'
    ]
    messages[rand(2)]
  end

  get '/notification_message' do
    flash[:notice] = random_notification_message
    redirect '/notification_message_rendered'
  end

  get '/notification_message_rendered' do
    erb :notification_message
  end

  get '/abtest' do
    erb :abtest
  end

  get '/abtest_cookies' do
    erb :abtest_cookies
  end

  get '/abtest_manual' do
    erb :abtest_manual
  end

  helpers do
    def protected!
      return if authorized?
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? and @auth.basic? and @auth.credentials and @auth.credentials == ['admin', 'admin']
    end
  end

  get '/basic_auth' do
    protected!
    erb :basic_auth
  end

  get '/basic_auth/' do
    protected!
    erb :basic_auth
  end

  get '/status_codes' do
    erb :status_codes
  end

  get '/status_codes/:status_code' do |status_code|
    status status_code.to_i
    @status_code = status_code
    erb :status_code, :layout => true
  end

  get '/javascript_error' do
    erb :javascript_error, :layout => false
  end

  get '/javascript_alerts' do
    erb :javascript_alerts
  end

  get '/redirect' do
    redirect '/status_codes'
  end

  get '/redirector' do
    erb :redirector
  end

  get '/login' do
    erb :login
  end

  post "/authenticate" do
    username = 'tomsmith'
    password = 'SuperSecretPassword!'

    if username == params[:username]
      if password == params[:password]
        session[:username] = params[:username]
        flash[:success] = 'You logged into a secure area!'
        redirect '/secure'
      else
        flash[:error] = 'Your password is invalid!'
      end
    else
      flash[:error] = 'Your username is invalid!'
    end
    redirect '/login'
  end

  get '/secure' do
    unless session[:username]
      flash[:error] = 'You must login to view the secure area!'
      redirect '/login'
    end
    erb :secure
  end

  get '/logout' do
    session[:username] = nil
    flash[:success] = 'You logged out of the secure area!'
    redirect "/login"
  end

  get '/dynamic_controls' do
    erb :dynamic_controls
  end

  get '/dynamic_loading' do
    erb :dynamic_loading
  end

  get '/dynamic_loading/1' do
    erb :dynamic_loading_1
  end

  get '/dynamic_loading/2' do
    erb :dynamic_loading_2
  end

  get '/tables' do
    erb :tables
  end

  get '/geolocation' do
    erb :geolocation
  end

  get '/large' do
    erb :large
  end

  get '/large/:nested_level' do |nested_level|
    @nested_level = nested_level.to_i
    erb :large
  end

  get '/drag_and_drop' do
    erb :drag_and_drop
  end

  get '/forgot_password' do
    erb :forgot_password
  end

  # Real email is sent when SMTP_ADDRESS is configured (e.g. SendGrid: user
  # "apikey", password = API key). Otherwise messages go to Mail's test
  # deliveries and are only logged.
  set :mail_from, ENV.fetch('MAIL_FROM', 'no-reply@the-internet.herokuapp.com')
  set :mail_delivery, if ENV['SMTP_ADDRESS']
    [:smtp, {
      address:              ENV['SMTP_ADDRESS'],
      port:                 Integer(ENV.fetch('SMTP_PORT', 587)),
      user_name:            ENV['SMTP_USERNAME'],
      password:             ENV['SMTP_PASSWORD'],
      domain:               ENV.fetch('SMTP_DOMAIN', 'the-internet.herokuapp.com'),
      authentication:       :plain,
      enable_starttls_auto: true
    }]
  else
    [:test, {}]
  end

  # The form accepts any address, so cap how often it can send mail.
  MAIL_LIMITS = { per_ip: 5, per_recipient: 3, window: 3600 }.freeze
  MAIL_LOG = Hash.new { |h, k| h[k] = [] }
  MAIL_LOG_LOCK = Mutex.new

  helpers do
    def client_ip
      # Heroku's router appends the connecting client's address last.
      request.env['HTTP_X_FORWARDED_FOR'].to_s.split(',').last&.strip || request.ip
    end

    def mail_allowed?(email)
      now = Time.now.to_i
      keys = { [:ip, client_ip] => MAIL_LIMITS[:per_ip], [:to, email.downcase] => MAIL_LIMITS[:per_recipient] }
      MAIL_LOG_LOCK.synchronize do
        keys.each_key { |k| MAIL_LOG[k].reject! { |t| t < now - MAIL_LIMITS[:window] } }
        return false if keys.any? { |k, limit| MAIL_LOG[k].size >= limit }

        keys.each_key { |k| MAIL_LOG[k] << now }
        true
      end
    end
  end

  post '/forgot_password' do
    require 'pony'
    email = params[:email].to_s.strip

    if email.match?(URI::MailTo::EMAIL_REGEXP) && mail_allowed?(email)
      method, options = settings.mail_delivery
      begin
        Pony.mail(
          from:     settings.mail_from,
          to:       email,
          subject:  "Forgot Password from the-internet",
          body:     "A forgot password retrieval was initiated from https://the-internet.herokuapp.com/forgot_password to #{email}.

  If this were a real message, you would likely see a link or some relevant text that would help you retrieve a password.

  If you want to test login, visit https://the-internet.herokuapp.com/login and use the following credentials:

  username: tomsmith
  password: SuperSecretPassword!",
          via:         method,
          via_options: options)
      rescue StandardError => e
        logger.error "forgot_password: mail delivery failed: #{e.class}: #{e.message}"
      end
    else
      logger.info 'forgot_password: invalid address or rate limited; not sending'
    end

    redirect '/email_sent'
  end

  get '/email_sent' do
    erb :email_sent
  end

  get '/checkboxes' do
    erb :checkboxes
  end

  get '/hovers' do
    erb :hovers
  end

  get '/key_presses' do
    erb :key_presses
  end

  get '/context_menu' do
    erb :context_menu
  end

  get '/slow' do
    erb :slow
  end

  get '/slow_external' do
    sleep 30
    status 200
  end

  get '/broken_images' do
    erb :broken_images
  end

  get '/dynamic_content' do
    @static_content = (params[:with_content] == 'static')
    @copy = []
    3.times { @copy << Faker::Lorem.sentence(word_count: 30) }
    @images = Dir.glob('public/img/avatars/*').map { |f| f.split('/').last }
    erb :dynamic_content
  end

  def shift_tracker
    if params[:pixel_shift]
      pixel_count = [0, params[:pixel_shift].to_i]
    else
      pixel_count = [0, 25]
    end

    if params[:mode] == 'random'
      @pixel_shift = pixel_count[rand(2)]
    else
      cookies[:page_visit_count] ||= '0'
      page_visit_count = cookies[:page_visit_count].to_i

      if page_visit_count.even?
        @pixel_shift = pixel_count[0]
      else
        @pixel_shift = pixel_count[1]
      end
      page_visit_count += 1
      cookies[:page_visit_count] = page_visit_count.to_s
    end
  end

  get '/shifting_content' do
    erb :shifting_content
  end

  get '/shifting_content/menu' do
    shift_tracker
    erb :shifting_content_menu
  end

  get '/shifting_content/image' do
    shift_tracker
    if params[:image_type] == 'simple'
      @file = '/img/avatars/Original-Facebook-Geek-Profile-Avatar-2.jpg'
    else
      @file = '/img/avatar.jpg'
    end
    erb :shifting_content_image
  end

  get '/shifting_content/list' do
    @copy = []
    @copy << "Important Information You're Looking For"
    @copy << "Nesciunt autem eum odit fuga tempora deleniti."
    @copy << "Vel aliquid dolores veniam enim nesciunt libero quaerat."
    @copy << "Sed deleniti blanditiis odio laudantium."
    @copy << "Et numquam et aliquam."
    @copy.shuffle!
    erb :shifting_content_list
  end

  get '/challenging_dom' do
    @text = %w[foo bar baz qux]
    @id = []
    20.times { @id << SecureRandom.uuid }
    erb :challenging_dom
  end

  get '/disappearing_elements' do
    markup = [%q(<ul>
                    <li><a href="/">Home</a></li>
                    <li><a href="/about/">About</a></li>
                    <li><a href="/contact-us/">Contact Us</a></li>
                    <li><a href="/portfolio/">Portfolio</a></li>
                    <li><a href="/gallery/">Gallery</a></li>
                  <ul>),
                %q(<ul>
                    <li><a href="/">Home</a></li>
                    <li><a href="/about/">About</a></li>
                    <li><a href="/contact-us/">Contact Us</a></li>
                    <li><a href="/portfolio/">Portfolio</a></li>
                  <ul>)]
    @payload = markup[rand(2)]
    erb :disappear
  end

  get '/typos' do
    @copy = ["Sometimes you'll see a typo, other times you won't.",
             "Sometimes you'll see a typo, other times you won,t."].at(rand(2))
    erb :typos
  end

  get '/infinite_scroll' do
    erb :infinite_scroll
  end

  get '/infinite_scroll/:number' do |number|
    "<br />#{Faker::Lorem.sentence(word_count: 300)}\
    <a href='/infinite_scroll/#{number.to_i + 1}'>next page</a>"
  end

  get '/floating_menu' do
    @copy = []
    10.times { @copy << Faker::Lorem.sentence(word_count: 300) }
    erb :floating_menu
  end

  get '/exit_intent' do
    erb :exit_intent
  end

  get '/entry_ad' do
    erb :entry_ad, locals: { dismissed_ad: session[:dismissed_ad] }
  end

  post '/entry_ad' do
    session[:dismissed_ad] = !session[:dismissed_ad]
  end

  get '/add_remove_elements/:number_of_elements?' do
    erb :add_remove_elements, locals: { number_of_elements: params[:number_of_elements].to_i }
  end

  get '/inputs' do
    erb :inputs
  end

  # subdirectories
  get '/subdirectories' do
    erb :'subdirectories/index'
  end

  %w[one two].each do |dir|
    get "/subdirectories/#{dir}" do
      erb :"/subdirectories/#{dir}/index"
    end
  end
  # /subdirectories
end
