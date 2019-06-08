desc 'Generate docs'
task :gen_docs  do
  update_readme
  update_examples_view
end

desc 'Pushes tags and code to master, develop, and heroku'
task :release do
  `git push origin master; git push --tags; git push heroku master`
end

def examples(file = 'examples.csv')
  require 'csv'
  examples = CSV.read(file, headers: true, header_converters: :symbol, converters: :all)

  examples.collect do |row|
    Hash[row.collect { |key, value| [key, value] }]
  end.sort_by { |key| key[:title] }

  # Returns an Array of Hashes in alphabetical order by :title like so:
  # {:title=>"A/B Testing", :url_path=>"/abtest", :notes=>nil}
  # {:title=>"Basic Auth", :url_path=>"/basic_auth", :notes=>"user and pass: admin"}
end

def convert_to_markdown_links(examples)
  markdown_string = ""
  examples.each do |example|
    markdown_string << "+ [#{example[:title]}](http://the-internet.herokuapp.com#{example[:url_path]})"
    markdown_string << " (#{example[:notes]})" if example[:notes]
    markdown_string << "\n"
  end
  markdown_string
end

def update_readme
  readme_text = File.read('README.template')
  readme_text.gsub!(/<%= examples %>/, convert_to_markdown_links(examples))
  File.open('README.md', 'w') { |file| file.puts readme_text }
end

def update_examples_view
  index_html = "<ul>\n"
  examples.each do |example|
    index_html << "  <li><a href='#{example[:url_path]}'>#{example[:title]}</a>"
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
  `bundle exec ruby server.rb`
end
