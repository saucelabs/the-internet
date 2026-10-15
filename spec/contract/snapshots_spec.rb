require_relative 'spec_helper'
require_relative 'pages'

# Compares each deterministic page's markup (#content, or the whole document
# for pages without the layout) to spec/contract/snapshots/<page>.html.
# Re-record after an intentional change with UPDATE_SNAPSHOTS=1 and review the diff.
SNAPSHOT_DIR = File.join(__dir__, 'snapshots')

describe 'Snapshots' do
  PAGES.each do |path, opts|
    next if opts[:snapshot] == false

    it path, *(opts[:unreleased] ? [:unreleased] : []) do
      file = File.join(SNAPSHOT_DIR, "#{snapshot_name(path)}.html")
      actual = Snapshot.of(Client.new(BASE_URL).get(path).body)

      if ENV['UPDATE_SNAPSHOTS'] || !File.exist?(file)
        File.write(file, actual)
        skip "recorded #{File.basename(file)}" unless ENV['UPDATE_SNAPSHOTS']
      else
        expect(actual).to eq File.read(file)
      end
    end
  end
end
