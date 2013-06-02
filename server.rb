require 'sinatra'

get '/upload' do
  erb :upload
end

p
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

def get_mime_type_for(filename)
  file_type = filename.split('.').last
  case file_type
    when 'jpg'
      'image/jpeg'
    when 'pdf'
      'application/pdf'
    else
      'application/octet-stream'
  end
end
