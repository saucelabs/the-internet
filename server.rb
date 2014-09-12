require 'bundler/setup'
require 'sinatra'
require 'sinatra/flash'
require 'zurb-foundation'
require 'compass'

enable :sessions

configure :production do
  require 'newrelic_rpm'
end

get '/' do
  erb :index
end

get '/upload' do
  erb :upload
end

post '/upload' do
  file = params['myfile']
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

def load_frame_get_actions
  frame_elements = %w(top bottom left right middle)
  frame_elements.each do |element|
    frame_path = "frame_#{element}".to_sym
    get "/frame_#{element}" do
      erb frame_path, :layout => false
    end
  end
end

load_frame_get_actions

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
  erb :new_window, :layout => false
end

get '/dropdown' do
  erb :dropdown
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
