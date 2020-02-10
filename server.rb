require 'bundler/setup'
require 'sinatra/base'
require 'sinatra/flash'
require 'sinatra/contrib'
require 'sinatra/cookies'
require 'zurb-foundation'
require 'compass'
require 'faker'

class Protected < Sinatra::Base
  register Sinatra::Flash

  get '/' do
    erb :digest_auth
  end

  def self.new(*)
    app = Rack::Auth::Digest::MD5.new(super) do |username|
      {'admin' => 'admin'}[username]
    end
    app.realm = 'Protected Area'
    app.opaque = 'secretkey'
    app
  end
end

class Public < Sinatra::Base
  helpers Sinatra::Cookies
  set :cookie_options, :domain => nil
  enable :sessions, :logging
  register Sinatra::Flash

  get '/' do
    erb :index
  end

  get '/upload' do
    erb :upload
  end

  post '/upload' do
    file = params['file']
    puts file.inspect
    File.open('public/uploads/' + file[:filename], 'w') do |f|
      f.write(file[:tempfile].read)
    end
    erb :uploaded, locals: { file: file }
  end

  get '/download' do
    @file_list = Dir.glob("public/uploads/*.*").map { |f| f.split('/').last }
    erb :download
  end

  get '/download/:filename' do |filename|
    mime_type = get_mime_type_for(filename)

    send_file "public/uploads/#{filename}",
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

    send_file "public/uploads/#{filename}",
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
    status status_code
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

  set :email_username, ENV['SENDGRID_USERNAME'] || ''
  set :email_password, ENV['SENDGRID_PASSWORD'] || ''
  set :email_address, 'dhaeffner@gmail.com'
  set :email_service, ENV['EMAIL_SERVICE'] || 'gmail.com'
  set :email_domain, ENV['SENDGRID_DOMAIN'] || 'localhost.localdomain'

  post '/forgot_password' do
    require 'pony'
    Pony.mail(
      from:     "no-reply@the-internet.herokuapp.com",
      to:       params[:email],
      subject:  "Forgot Password from the-internet",
      body:     "A forgot password retrieval was initiated from http://the-internet.herokuapp.com/forgot_password to #{params[:email]}.

  If this were a real message, you would likely see a link or some relevant text that would help you retrieve a password.

  If you want to test login, visit http://the-internet.herokuapp.com/login and use the following credentials:

  username: tomsmith
  password: SuperSecretPassword!",
      via:      'smtp',
      via_options: {
        address:              'smtp.' + settings.email_service,
        port:                 '587',
        enable_starttls_auto: true,
        user_name:            settings.email_username,
        password:             settings.email_password,
        authentication:       :plain,
        domain:               settings.email_domain
      })

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
    3.times { @copy << Faker::Lorem.sentence(30) }
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
    require 'uuid'
    @text = %w(foo bar baz qux)
    @id = []
    20.times { @id << UUID.new.generate }
    erb :challenging_dom
  end

  get '/disappearing_elements' do
    markup = [%q{<ul>
                    <li><a href="/">Home</a></li>
                    <li><a href="/about/">About</a></li>
                    <li><a href="/contact-us/">Contact Us</a></li>
                    <li><a href="/portfolio/">Portfolio</a></li>
                    <li><a href="/gallery/">Gallery</a></li>
                  <ul>},
                %q{<ul>
                    <li><a href="/">Home</a></li>
                    <li><a href="/about/">About</a></li>
                    <li><a href="/contact-us/">Contact Us</a></li>
                    <li><a href="/portfolio/">Portfolio</a></li>
                  <ul>}]
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
    "<br />#{Faker::Lorem.sentence(300)}\
    <a href='/infinite_scroll/#{number.to_i + 1}'>next page</a>"
  end

  get '/floating_menu' do
    @copy = []
    10.times { @copy << Faker::Lorem.sentence(300) }
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
end
