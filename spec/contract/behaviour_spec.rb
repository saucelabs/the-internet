require_relative 'spec_helper'
require 'digest'
require 'json'
require 'erb'
require 'securerandom'
require 'websocket/driver'
require_relative 'support/echo_client'

REPO_ROOT = File.expand_path('../..', __dir__)

describe 'Behaviour' do
  def flash(res)
    html(res).at_css('#flash-messages #flash')
  end

  describe 'Basic auth' do
    %w[/basic_auth /basic_auth/ /download_secure].each do |path|
      it "#{path} challenges without credentials" do
        res = client.get(path)
        expect(res.code).to eq '401'
        expect(res['www-authenticate']).to eq 'Basic realm="Restricted Area"'
      end

      it "#{path} rejects wrong credentials" do
        req = Net::HTTP::Get.new(path).tap { |r| r.basic_auth('admin', 'nope') }
        expect(client.request(req).code).to eq '401'
      end

      it "#{path} accepts admin/admin" do
        req = Net::HTTP::Get.new(path).tap { |r| r.basic_auth('admin', 'admin') }
        expect(client.request(req).code).to eq '200'
      end
    end
  end

  describe 'Modern downloads' do
    {
      'inline' => 'inline; filename="inline.txt"',
      'utf8' => %(attachment; filename="resume.txt"; filename*=UTF-8''r%C3%A9sum%C3%A9.txt),
      'spaces' => 'attachment; filename="my report 2026.txt"',
      'no_name' => 'attachment',
      'report.json' => 'attachment; filename="report.json"'
    }.each do |name, disposition|
      it "sends #{name} with its Content-Disposition" do
        res = client.get("/download_modern/file/#{name}")
        expect(res.code).to eq '200'
        expect(res['content-disposition']).to eq disposition
      end
    end

    it 'answers 404 for other names' do
      expect(client.get('/download_modern/file/other').code).to eq '404'
    end
  end

  describe 'Visual differences' do
    it 'turns on each change from the URL and ignores unknown values' do
      text = ->(path) { html(client.get(path)).at_css('#active-changes').text }
      expect(text.call('/visual_diff?shift=999&color=purple&font=large')).to eq 'Changes: shift 50px, large font'
      expect(text.call('/visual_diff?hide_logo=true&typo=true')).to eq 'Changes: logo hidden, typo'
    end
  end

  describe 'Locale' do
    def greeting(path, headers = {})
      html(client.get(path, headers)).at_css('#greeting').text
    end

    it 'greets in the language of Accept-Language' do
      expect(greeting('/locale', 'Accept-Language' => 'fr-CA,fr;q=0.9,en;q=0.8')).to eq 'Bonjour !'
      expect(greeting('/locale', 'Accept-Language' => 'en;q=0.5, de')).to eq 'Hallo!'
      expect(greeting('/locale', 'Accept-Language' => 'pt-BR')).to eq 'Hello!'
      expect(greeting('/locale')).to eq 'Hello!'
    end

    it 'lets ?lang= win over the header' do
      expect(greeting('/locale?lang=ja', 'Accept-Language' => 'es')).to eq 'こんにちは！'
      expect(greeting('/locale?lang=xx', 'Accept-Language' => 'es')).to eq '¡Hola!'
    end
  end

  describe 'Cookie consent' do
    it 'shows the banner until the cookie is set' do
      expect(html(client.get('/cookie_consent')).at_css('#cookie-banner')).not_to be_nil
      client.cookies['cookie_consent'] = 'all'
      doc = html(client.get('/cookie_consent'))
      expect(doc.at_css('#cookie-banner')).to be_nil
      expect(doc.at_css('#consent-status').text).to eq 'Analytics cookies: allowed'
    end

    it 'ignores unknown values' do
      client.cookies['cookie_consent'] = 'bogus'
      expect(html(client.get('/cookie_consent')).at_css('#cookie-banner')).not_to be_nil
    end

    it 'forgets the choice' do
      client.cookies['cookie_consent'] = 'necessary'
      res = client.get('/cookie_consent/reset')
      expect(res.code).to eq '302'
      expect(res['set-cookie']).to match(/cookie_consent=;.*max-age=0/i)
    end
  end

  describe 'Live updates' do
    it 'streams Server-Sent Events and ends with done' do
      res = client.get('/live_updates/events?count=2&interval=200')
      expect(res['content-type']).to start_with 'text/event-stream'
      expect(res.body).to eq "id: 1\ndata: Update 1 of 2\n\nid: 2\ndata: Update 2 of 2\n\nevent: done\ndata: No more updates\n\n"
    end
  end

  describe 'WebSocket' do
    it 'answers a plain request with 426' do
      res = client.get('/websocket/echo')
      expect(res.code).to eq '426'
      expect(res['upgrade']).to eq 'websocket'
    end

    it 'greets, echoes text messages and closes cleanly' do
      ws = EchoClient.new(BASE_URL)
      driver = WebSocket::Driver.client(ws)
      received = []
      closed = nil
      driver.on(:open) { driver.text('hello') }
      driver.on(:message) { |event| received << event.data; driver.close if received.size == 2 }
      driver.on(:close) { |event| closed = event.code }
      driver.start
      Timeout.timeout(10) { driver.parse(ws.socket.readpartial(4096)) until closed }
      expect(received).to eq ['Connected. Send a message and the server sends it back.', 'Echo: hello']
      expect(closed).to eq 1000
    ensure
      ws&.socket&.close
    end
  end

  describe 'Slow and failing API' do
    it 'fails the first attempts with the chosen status, then answers' do
      res = client.get('/slow_api/data?fail=2&status=429&attempt=2')
      expect(res.code).to eq '429'
      expect(res['retry-after']).to eq '1'
      expect(JSON.parse(res.body)).to eq('error' => 'Attempt 2 failed with 429')
      res = client.get('/slow_api/data?fail=2&status=429&attempt=3')
      expect(res.code).to eq '200'
      expect(JSON.parse(res.body)).to eq('message' => 'Data loaded on attempt 3')
    end

    it 'uses 500 for unknown statuses' do
      expect(client.get('/slow_api/data?fail=1&status=418').code).to eq '500'
    end
  end

  describe 'Network & Console' do
    it 'sends a report-only CSP for images' do
      expect(client.get('/network_console')['content-security-policy-report-only']).to eq "img-src 'self'"
    end

    it 'serves JSON data' do
      res = client.get('/network_console/data')
      expect(res['content-type']).to start_with 'application/json'
      expect(JSON.parse(res.body)).to eq('fruit' => 'apple', 'count' => 3)
    end
  end

  describe 'Form validation' do
    let(:valid) { { username: 'ana', email: 'ana@example.com', password: 'longenough', terms: 'on' } }

    it 'accepts a valid form' do
      res = client.post('/form_validation', valid)
      expect(res.code).to eq '200'
      expect(JSON.parse(res.body)).to eq('message' => 'Account created for ana')
    end

    it 'answers 422 with errors per field' do
      res = client.post('/form_validation', valid.merge(username: 'tomsmith', password: 'short', terms: ''))
      expect(res.code).to eq '422'
      expect(JSON.parse(res.body)['errors']).to eq(
        'username' => 'Username is already taken',
        'password' => 'Password must be at least 8 characters',
        'terms' => 'You must accept the terms'
      )
    end

    it 'shows the success message' do
      req = Net::HTTP::Get.new('/basic_auth').tap { |r| r.basic_auth('admin', 'admin') }
      expect(client.request(req).body).to include 'Congratulations! You must have the proper credentials.'
    end

    it 'serves secure downloads with credentials' do
      req = Net::HTTP::Get.new('/download_secure/some-file.txt').tap { |r| r.basic_auth('admin', 'admin') }
      expect(client.request(req).code).to eq '200'
    end
  end

  describe 'Digest auth' do
    def challenge(path)
      res = client.get(path)
      expect(res.code).to eq '401'
      res['www-authenticate']
    end

    def digest_get(path, user, pass)
      header = challenge(path)
      params = header.delete_prefix('Digest ').scan(/(\w+)="([^"]*)"/).to_h
      cnonce = SecureRandom.hex(8)
      ha1 = Digest::MD5.hexdigest("#{user}:#{params['realm']}:#{pass}")
      ha2 = Digest::MD5.hexdigest("GET:#{path}")
      response = Digest::MD5.hexdigest("#{ha1}:#{params['nonce']}:00000001:#{cnonce}:auth:#{ha2}")
      auth = %(Digest username="#{user}", realm="#{params['realm']}", nonce="#{params['nonce']}", ) +
             %(uri="#{path}", qop=auth, nc=00000001, cnonce="#{cnonce}", response="#{response}", ) +
             %(opaque="#{params['opaque']}")
      client.get(path, 'Authorization' => auth)
    end

    it 'challenges with realm "Protected Area" and qop=auth' do
      header = challenge('/digest_auth')
      expect(header).to start_with 'Digest '
      expect(header).to include 'realm="Protected Area"', 'qop="auth"', 'nonce="', 'opaque="'
    end

    %w[/digest_auth /digest_auth/].each do |path|
      it "#{path} accepts admin/admin" do
        res = digest_get(path, 'admin', 'admin')
        expect(res.code).to eq '200'
        expect(res.body).to include 'Digest Auth', 'Congratulations! You must have the proper credentials.'
      end
    end

    it 'rejects a wrong password' do
      expect(digest_get('/digest_auth', 'admin', 'nope').code).to eq '401'
    end
  end

  describe 'Form authentication' do
    def login(username, password)
      client.post('/authenticate', username: username, password: password)
    end

    it 'rejects an unknown username' do
      res = login('nobody', 'SuperSecretPassword!')
      # Sinatra answers redirects to non-GET requests with 303 See Other.
      expect(res.code).to eq '303'
      expect(path_of(res['location'])).to eq '/login'
      el = flash(client.follow(res))
      expect(el['class'].split).to include 'flash', 'error'
      expect(el.text).to include 'Your username is invalid!'
    end

    it 'rejects a wrong password' do
      res = login('tomsmith', 'nope')
      expect(flash(client.follow(res)).text).to include 'Your password is invalid!'
    end

    it 'logs in, shows the secure area and logs out' do
      res = login('tomsmith', 'SuperSecretPassword!')
      expect(res.code).to eq '303'
      expect(path_of(res['location'])).to eq '/secure'

      secure = client.follow(res)
      expect(secure.code).to eq '200'
      el = flash(secure)
      expect(el['class'].split).to include 'flash', 'success'
      expect(el.text).to include 'You logged into a secure area!'
      expect(secure.body).to include 'Secure Area', 'href="/logout"'

      out = client.get('/logout')
      expect(path_of(out['location'])).to eq '/login'
      expect(flash(client.follow(out)).text).to include 'You logged out of the secure area!'

      again = client.get('/secure')
      expect(path_of(again['location'])).to eq '/login'
    end

    it 'redirects anonymous visitors away from /secure' do
      res = client.get('/secure')
      expect(res.code).to eq '302'
      expect(flash(client.follow(res)).text).to include 'You must login to view the secure area!'
    end
  end

  describe 'Notification messages' do
    it 'redirects and shows one of the two notices' do
      res = client.get('/notification_message')
      expect(res.code).to eq '302'
      expect(path_of(res['location'])).to eq '/notification_message_rendered'
      el = flash(client.follow(res))
      expect(el['class'].split).to include 'flash', 'notice'
      expect(['Action successful', 'Action unsuccesful, please try again']).to include el.children.first.text.strip
    end
  end

  describe 'Status codes' do
    %w[200 301 404 500].each do |code|
      it "/status_codes/#{code} returns #{code}" do
        res = client.get("/status_codes/#{code}")
        expect(res.code).to eq code
        expect(res.body).to include "This page returned a #{code} status code."
      end
    end

    it '/redirect redirects to /status_codes' do
      res = client.get('/redirect')
      expect(res.code).to eq '302'
      expect(path_of(res['location'])).to eq '/status_codes'
    end

    it 'unknown paths return 404' do
      expect(client.get('/this-page-does-not-exist').code).to eq '404'
    end
  end

  describe 'Downloads' do
    it 'lists the seeded file' do
      links = html(client.get('/download')).css('#content a').map { |a| a['href'] }
      expect(links).to include 'download/some-file.txt'
    end

    it 'serves the seeded file as an attachment' do
      res = client.get('/download/some-file.txt')
      expect(res.code).to eq '200'
      expect(res['content-disposition']).to include 'attachment', 'some-file.txt'
      # On live, visitors can overwrite the seeded file through /upload.
      next unless LOCAL

      expect(res.body.b).to eq File.binread(File.join(REPO_ROOT, 'public/uploads/some-file.txt'))
    end
  end

  describe 'JQuery UI menu downloads' do
    %w[menu.pdf menu.csv menu.xls].each do |file|
      it "serves #{file} as an attachment" do
        res = client.get("/download/jqueryui/menu/#{file}")
        expect(res.code).to eq '200'
        expect(res['content-disposition']).to include 'attachment', file
        expect(res.body.b).to eq File.binread(File.join(REPO_ROOT, 'public/uploads/jqueryui/menu', file)) if LOCAL
      end
    end
  end

  describe 'Autocomplete suggestions' do
    it 'returns names that start with the query as JSON' do
      res = client.get('/autocomplete/suggestions?q=gr')
      expect(res.code).to eq '200'
      expect(res['content-type']).to start_with 'application/json'
      expect(JSON.parse(res.body)).to eq %w[Grape Grapefruit]
    end

    it 'returns an empty list for an empty or unknown query' do
      expect(JSON.parse(client.get('/autocomplete/suggestions?q=').body)).to eq []
      expect(JSON.parse(client.get('/autocomplete/suggestions?q=zz').body)).to eq []
    end
  end

  describe 'Uploads', :writes do
    let(:name) { "contract-#{SecureRandom.hex(4)}.txt" }
    after { File.delete(File.join(REPO_ROOT, 'public/uploads', name)) if LOCAL && File.exist?(File.join(REPO_ROOT, 'public/uploads', name)) }

    it 'accepts a multipart upload and lists it for download' do
      res = client.post_multipart('/upload', [['file', StringIO.new('hello'), { filename: name, content_type: 'text/plain' }]])
      expect(res.code).to eq '200'
      expect(html(res).at_css('#uploaded-files').text.strip).to eq name
      expect(client.get("/download/#{name}").body).to eq 'hello'
    end

    it 'does not let uploads overwrite the seeded file' do
      seeded = File.binread(File.join(REPO_ROOT, 'public/uploads/some-file.txt'))
      res = client.post_multipart('/upload', [['file', StringIO.new('overwritten'), { filename: 'some-file.txt', content_type: 'text/plain' }]])
      expect(res.code).to eq '200'
      expect(client.get('/download/some-file.txt').body.b).to eq seeded
    end

    it 'answers 500 with an explanation when no file is chosen' do
      res = client.post('/upload', file: '')
      expect(res.code).to eq '500'
      expect(html(res).at_css('#upload-error').text).to include 'No file was chosen'
    end

    it 'rejects programs' do
      res = client.post_multipart('/upload', [['file', StringIO.new('MZ'), { filename: 'contract.exe', content_type: 'application/octet-stream' }]])
      expect(res.code).to eq '422'
      expect(html(res).at_css('#upload-error').text).to include ".exe files can't be uploaded."
      expect(client.get('/download').body).not_to include 'contract.exe'
    end

    it 'rejects files over 2 MB' do
      res = client.post_multipart('/upload', [['file', StringIO.new('a' * (2 * 1024 * 1024 + 1)), { filename: name, content_type: 'text/plain' }]])
      expect(res.code).to eq '413'
      expect(client.get('/download').body).not_to include name
    end
  end

  describe 'Uploads cleanup', :writes do
    let(:dir) { File.join(REPO_ROOT, 'public/uploads') }
    let(:hex) { SecureRandom.hex(4) }
    before { skip 'needs the app on this machine' unless LOCAL }
    after { Dir.glob(File.join(dir, "contract-cleanup-#{hex}-*")).each { |f| File.delete(f) } }

    def upload_file(name, age: 0)
      path = File.join(dir, name)
      File.write(path, 'hello')
      File.utime(Time.now - age, Time.now - age, path)
      path
    end

    it 'deletes uploads older than an hour' do
      old = upload_file("contract-cleanup-#{hex}-old.txt", age: 2 * 60 * 60)
      fresh = upload_file("contract-cleanup-#{hex}-fresh.txt")
      body = client.get('/download').body
      expect(body).not_to include File.basename(old)
      expect(body).to include File.basename(fresh)
      expect(File.exist?(old)).to be false
    end

    it 'keeps only the newest 100 uploads' do
      oldest = upload_file("contract-cleanup-#{hex}-0.txt", age: 30 * 60)
      100.times { |i| upload_file("contract-cleanup-#{hex}-#{i + 1}.txt") }
      client.get('/download')
      expect(File.exist?(oldest)).to be false
      expect(File.exist?(File.join(dir, "contract-cleanup-#{hex}-100.txt"))).to be true
    end

    it 'never deletes the seeded files' do
      seeded = %w[some-file.txt textfile.txt sample.csv sample.json sample.pdf]
      seeded.each { |f| File.utime(Time.now - 48 * 60 * 60, Time.now - 48 * 60 * 60, File.join(dir, f)) }
      client.get('/download')
      seeded.each { |f| expect(File.exist?(File.join(dir, f))).to be(true), "#{f} was deleted" }
    end
  end

  describe 'Upload file names', :writes do
    let(:hex) { SecureRandom.hex(4) }
    let(:cleaned) { "contract__b_#{hex}.txt" }
    after { File.delete(File.join(REPO_ROOT, 'public/uploads', cleaned)) if LOCAL && File.exist?(File.join(REPO_ROOT, 'public/uploads', cleaned)) }

    it 'stores the file under a cleaned name' do
      res = client.post_multipart('/upload', [['file', StringIO.new('hello'), { filename: "contract <b>#{hex}.txt", content_type: 'text/plain' }]])
      expect(res.code).to eq '200'
      download = client.get('/download')
      expect(download.body).not_to include '<b>'
      expect(html(download).css('#content a').map(&:text)).to include cleaned
      expect(client.get("/download/#{cleaned}").body).to eq 'hello'
    end

    it 'rejects a name without letters or digits' do
      res = client.post_multipart('/upload', [['file', StringIO.new('hello'), { filename: '<>', content_type: 'text/plain' }]])
      expect(res.code).to eq '422'
      expect(html(res).at_css('#upload-error').text).to include 'at least one letter or digit'
    end
  end

  describe 'Download lists escape file names', :writes do
    let(:name) { "contract <b>#{SecureRandom.hex(4)}.txt" }
    let(:path) { File.join(REPO_ROOT, 'public/uploads', name) }
    before do
      skip 'needs the app on this machine' unless LOCAL
      File.write(path, 'hello')
    end
    after { File.delete(path) if File.exist?(path) }

    {
      '/download' => {},
      '/download_secure' => { 'Authorization' => "Basic #{['admin:admin'].pack('m0')}" }
    }.each do |page, headers|
      it "#{page} shows the name as text" do
        res = client.get(page, headers)
        expect(res.code).to eq '200'
        expect(res.body).not_to include '<b>'
        link = html(res).css('#content a').find { |a| a.text == name }
        expect(link['href']).to eq "#{page.delete_prefix('/')}/#{ERB::Util.url_encode(name)}"
      end
    end
  end

  describe 'Sample downloads' do
    %w[some-file.txt textfile.txt sample.csv sample.json sample.pdf].each do |file|
      it "lists and serves #{file}" do
        expect(client.get('/download').body).to include "download/#{file}"
        res = client.get("/download/#{file}")
        expect(res.code).to eq '200'
        expect(res['content-disposition']).to include 'attachment'
        expect(res.body.b).to eq File.binread(File.join(REPO_ROOT, 'public/uploads', file)) if LOCAL
      end
    end
  end

  describe 'Two-factor login' do
    def login(password = 'SuperSecretPassword!')
      client.post('/two_factor/authenticate', username: 'tomsmith', password: password)
    end

    def code_page
      client.follow(login)
    end

    it 'rejects a wrong password' do
      res = login('nope')
      expect(path_of(res['location'])).to eq '/two_factor'
      expect(flash(client.follow(res)).text).to include 'Your username or password is invalid!'
    end

    it 'asks for a code in a password field, then opens the secure area' do
      page = html(code_page)
      code = page.at_css('#otp-code').text
      expect(code).to match(/\A\d{6}\z/)
      expect(page.at_css('input#code')['type']).to eq 'password'

      res = client.post('/two_factor/verify', code: code)
      expect(path_of(res['location'])).to eq '/two_factor/secure'
      secure = client.follow(res)
      expect(flash(secure).text).to include 'You logged in with two-factor authentication!'

      out = client.get('/two_factor/logout')
      expect(flash(client.follow(out)).text).to include 'You logged out of the secure area!'
      expect(path_of(client.get('/two_factor/secure')['location'])).to eq '/two_factor'
    end

    it 'rejects a wrong code' do
      code_page
      res = client.post('/two_factor/verify', code: '000000x')
      expect(path_of(res['location'])).to eq '/two_factor/code'
      expect(flash(client.follow(res)).text).to include 'Your code is invalid!'
    end
  end

  describe 'Large form' do
    it 'echoes every submitted value and masks the password' do
      res = client.post('/large_form', 'first_name' => 'Ana', 'languages[]' => %w[English Spanish], 'password' => 'secret')
      rows = html(res).css('#submitted-data tbody tr').to_h { |tr| tr.css('td').map { |td| td.text.strip } }
      expect(rows).to include('first_name' => 'Ana', 'languages' => 'English, Spanish', 'password' => '******')
    end
  end

  describe 'Forgot password', :writes do
    it 'redirects to /email_sent' do
      res = client.post('/forgot_password', email: 'contract-test@example.com')
      expect(res.code).to eq '303'
      expect(path_of(res['location'])).to eq '/email_sent'
    end

    it 'redirects to /email_sent even for an invalid address' do
      res = client.post('/forgot_password', email: 'not-an-email')
      expect(res.code).to eq '303'
      expect(path_of(res['location'])).to eq '/email_sent'
    end
  end

  describe 'Entry ad' do
    it 'accepts the dismiss toggle' do
      expect(client.post('/entry_ad').code).to eq '200'
    end
  end

  describe 'Parameterised examples' do
    it '/add_remove_elements/:n renders n Delete buttons' do
      buttons = html(client.get('/add_remove_elements/3')).css('#elements button')
      expect(buttons.map(&:text)).to eq ['Delete'] * 3
    end

    it '/large/:n nests n levels' do
      res = client.get('/large/3')
      expect(res.body).to include 'These examples are nested 3 levels deep.'
      expect(html(res).css('#large-table thead th').size).to eq 3
    end

    it '/infinite_scroll/:n links to the next page' do
      expect(client.get('/infinite_scroll/4').body).to include "href='/infinite_scroll/5'"
    end

    it '/dynamic_content?with_content=static keeps the first two avatars fixed' do
      srcs = 2.times.map { html(client.get('/dynamic_content?with_content=static')).css('#content img').first(2).map { |i| i['src'] } }
      expect(srcs.uniq.size).to eq 1
    end
  end

  describe 'Shifting content' do
    def shift(res)
      res.body[/left: -(\d+)px/, 1].to_i
    end

    it 'alternates 0 and 25 pixels per visit (cookie)' do
      expect(3.times.map { shift(client.get('/shifting_content/menu')) }).to eq [0, 25, 0]
    end

    it 'honours ?pixel_shift' do
      client.get('/shifting_content/menu?pixel_shift=100')
      expect(shift(client.get('/shifting_content/menu?pixel_shift=100'))).to eq 100
    end

    it '/shifting_content/list shows the five items' do
      body = client.get('/shifting_content/list').body
      expect(body).to include "Important Information You're Looking For", 'Et numquam et aliquam.'
    end
  end

  describe 'Random examples stay within their variants' do
    it '/disappearing_elements shows 4 or 5 menu items' do
      count = html(client.get('/disappearing_elements')).css('#content ul li').size
      expect([4, 5]).to include count
    end

    it '/typos shows one of the two sentences' do
      body = client.get('/typos').body
      expect(body.include?("Sometimes you'll see a typo, other times you won't.") ||
             body.include?("Sometimes you'll see a typo, other times you won,t.")).to be true
    end

    it '/challenging_dom has three buttons with UUID ids' do
      buttons = html(client.get('/challenging_dom')).css('#content a.button')
      expect(buttons.size).to eq 3
      buttons.each { |b| expect(b['id']).to match(/\A\h{8}-\h{4}-\h{4}-\h{4}-\h{12}\z/) }
    end
  end
end
