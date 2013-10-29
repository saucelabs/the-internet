describe "File", :depth => 'shallow' do

  it 'Upload' do
    visit 'http://localhost:9292/upload'
    wait_for { displayed? id: 'file-upload' }
    type id: 'file-upload', '/Users/more/Desktop/fake_image.jpg'
    submit id: 'file-upload'

    uploaded_image = attribute_for css: 'img', 'src'
    uploaded_image.should =~ /fake_image.jpg/
  end

  it 'Download' do
    visit 'http://localhost:9292/download'
    link = attribute_for css: 'a', 'href'
    response = download_file_from link
    response.headers[:content_type].should == 'image/jpeg'
    response.headers[:content_length].to_i.should > 0
  end

end
