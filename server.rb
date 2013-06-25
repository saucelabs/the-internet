require 'sinatra'

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

get '/dropdown' do
  erb :dropdown
end
