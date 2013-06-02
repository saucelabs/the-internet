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
  send_file "public/uploads/#{filename}",
    :filename => filename,
    :type => 'Application/octet-stream'
end
