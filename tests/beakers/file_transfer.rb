describe "File", :depth => 'shallow' do

  let(:upload) { @formula_lab.mix 'upload' }

  it 'Upload' do
    upload.file '~/fake_image.jpg'
    upload.uploaded_image_source.should =~ /fake_image.jpg/
  end

  #it 'Download' do
  #  visit 'http://localhost:9292/download'
  #  link = attribute_for css: 'a', 'href'
  #  response = download_file_from link
  #  response.headers[:content_type].should == 'image/jpeg'
  #  response.headers[:content_length].to_i.should > 0
  #end

end
