describe "File", :depth => 'shallow' do

  it 'Upload' do
    @driver.get 'http://localhost:9292/upload'
    uploader = @driver.find_element(id: 'file-upload')
    uploader.send_keys '/Users/more/Desktop/fake_image.jpg'
    uploader.submit

    uploaded_image = @driver.find_element(css: 'img').attribute('src')
    uploaded_image.should =~ /fake_image.jpg/
  end

  it 'Download' do
    require 'rest-client'
    @driver.get 'http://localhost:9292/download'
    link = @driver.find_element(css: 'a').attribute('href')
    response = RestClient.head link
    response.headers[:content_type].should == 'image/jpeg'
    response.headers[:content_length].to_i.should > 0
  end

end
