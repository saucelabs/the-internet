require 'sinatra'

get '/upload' do
  erb :upload
end

post '/upload' do
#  File.open('uploads/' + params['myfile'][:filename], 'w') do |f|
#    f.write(params['myfile'][:filemame].read)
#  end
  return "The file was ignored."
end
