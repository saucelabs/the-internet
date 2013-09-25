# Encoding: utf-8

describe 'Home Page', depth: 'shallow' do

  let(:home)   { @formula_lab.mix('home')                     }

  it 'Lite Account' do
    home.heading.should eq 'Welcome to the Internet'
  end

end
