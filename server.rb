require 'sinatra'
require 'sinatra/flash'

enable :sessions

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

get '/frames' do
  erb :frames, :layout => false
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
