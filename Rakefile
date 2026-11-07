desc 'Generate docs'
task :gen_docs  do
  update_readme
  update_examples_view
end

def examples(file = 'examples.csv')
  require 'csv'
  examples = CSV.read(file, headers: true, header_converters: :symbol, converters: :all)

  examples.collect do |row|
    Hash[row.collect { |key, value| [key, value] }]
  end.sort_by { |key| key[:title] }

  # Returns an Array of Hashes in alphabetical order by :title like so:
  # {:title=>"A/B Testing", :url_path=>"/abtest", :notes=>nil, :description=>"Content that changes between visits"}
  # {:title=>"Basic Auth", :url_path=>"/basic_auth", :notes=>"user and pass: admin", :description=>"..."}
end

def convert_to_markdown_links(examples)
  markdown_string = ""
  examples.each do |example|
    markdown_string << "+ [#{example[:title]}](https://the-internet.herokuapp.com#{example[:url_path]})"
    markdown_string << " (#{example[:notes]})" if example[:notes]
    # HTML tags like <select> go in backticks, or GitHub drops them.
    markdown_string << " - #{example[:description].gsub(/<\w+>/) { |tag| "`#{tag}`" }}" if example[:description]
    markdown_string << "\n"
  end
  markdown_string
end

def update_readme
  readme_text = File.read('README.template')
  readme_text.gsub!(/<%= examples %>/, convert_to_markdown_links(examples))
  File.open('README.md', 'w') { |file| file.puts readme_text }
end

# The description and the full text (title) are attributes, so the text of each <li> stays the same.
def update_examples_view
  require 'erb'
  index_html = "<ul>\n"
  examples.each do |example|
    index_html << "  <li"
    full_text = [example[:title], example[:notes] && "(#{example[:notes]})", example[:description] && "- #{example[:description]}"].compact.join(' ')
    index_html << " title='#{ERB::Util.html_escape(full_text)}'"
    index_html << " data-description='#{ERB::Util.html_escape(example[:description])}'" if example[:description]
    index_html << "><a href='#{example[:url_path]}'>#{example[:title]}</a>"
    index_html << " (#{example[:notes]})" if example[:notes]
    index_html << "</li>"
    index_html << "\n"
  end
  index_html << "</ul>"
  File.open('views/examples.erb', 'w') { |file| file.puts index_html }
end

desc 'Cleanup uploaded files'
task :rm_uploads do
  `rm -rf public/uploads/*.jpg`
end

desc 'Run server'
task :run do
  exec 'bundle exec rackup'
end

# Boots the app with puma on a free port and yields its base URL.
# Two puma workers, like production, so the specs also cover requests spread over processes.
def with_app
  require 'net/http'
  require 'tmpdir'
  require 'socket'
  port = Addrinfo.tcp('127.0.0.1', 0).bind { |s| s.local_address.ip_port }
  users_dir = Dir.mktmpdir('api_users')
  env = { 'PORT' => port.to_s, 'WEB_CONCURRENCY' => ENV.fetch('WEB_CONCURRENCY', '2'), 'API_USERS_DIR' => users_dir }
  pid = spawn(env, 'bundle exec puma -C config/puma.rb -q', out: File::NULL)
  begin
    50.times do
      break if (Net::HTTP.get_response(URI("http://127.0.0.1:#{port}/")) rescue nil)
      sleep 0.2
    end
    yield "http://127.0.0.1:#{port}"
  ensure
    Process.kill('TERM', pid)
    Process.wait(pid)
    FileUtils.rm_rf(users_dir)
  end
end

desc 'Boot the app and run the HTTP contract suite against it'
task :contract do
  with_app { |url| sh({ 'BASE_URL' => url }, 'bundle exec rspec spec/contract') }
end

desc 'Boot the app and run the browser suite against it (BROWSER, HEADLESS, TARGET, E2E_PROCESSES)'
task :e2e do
  processes = ENV.fetch('E2E_PROCESSES', '4')
  with_app { |url| sh({ 'BASE_URL' => url }, "bundle exec parallel_rspec -n #{processes} spec/e2e") }
end

desc 'Run the in-process tests (users store and login, with a test clock)'
task :unit do
  sh 'bundle exec rspec spec/unit'
end

task default: %i[unit contract]
