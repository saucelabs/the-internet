require_relative 'spec_helper'
require_relative 'pages'

# Selectors in the shared layout that external test suites rely on.
LAYOUT_SELECTORS = ['#flash-messages', '#content', '#page-footer'].freeze

describe 'Pages' do
  PAGES.each do |path, opts|
    tags = opts[:unreleased] ? [:unreleased] : []

    describe path, *tags do
      before(:all) { @res = Client.new(BASE_URL).get(path) }

      it 'returns 200 as HTML' do
        expect(@res.code).to eq '200'
        expect(@res['content-type']).to start_with 'text/html'
      end

      it "contains #{opts[:text].inspect}" do
        expect(@res.body).to include opts[:text]
      end

      if opts.fetch(:layout, true)
        it 'renders the shared layout' do
          doc = Nokogiri::HTML(@res.body)
          LAYOUT_SELECTORS.each { |sel| expect(doc.at_css(sel)).not_to be_nil, "missing #{sel}" }
          expect(doc.at_css('title').text).to eq 'The Internet'
          expect(doc.at_css('#page-footer').text).to include 'Powered by Elemental Selenium'
        end
      end
    end
  end

  it 'lists every example from examples.csv on the index' do
    require 'csv'
    expected = CSV.read(File.expand_path('../../examples.csv', __dir__), headers: true)
                  .map { |r| [r['title'], r['url_path']] }.sort
    links = html(client.get('/')).css('#content ul li a').map { |a| [a.text, a['href']] }.sort
    expect(links).to eq expected
  end

  it 'links every example on the index to a working page' do
    html(client.get('/')).css('#content ul li a').each do |a|
      code = begin
        Client.new(BASE_URL).get(a['href']).code
      rescue Net::ReadTimeout
        'timeout'
      end
      # Auth-protected examples answer 401; /notification_message redirects.
      expect(%w[200 302 401]).to include(code), "#{a['href']} returned #{code}"
    end
  end
end
