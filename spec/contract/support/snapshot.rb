require 'nokogiri'

# Canonical, whitespace-insensitive rendering of an HTML fragment:
# one node per line, attributes sorted. Diffs read like a DOM tree.
module Snapshot
  module_function

  # Pages rendered with the layout are snapshotted from #content only, so the
  # shared chrome (header/footer/head) can be restyled without touching them.
  def of(html)
    doc = Nokogiri::HTML(html)
    root = doc.at_css('#content') || doc.root
    lines = []
    walk(root, 0, lines)
    lines.join("\n") + "\n"
  end

  def walk(node, depth, lines)
    pad = '  ' * depth
    case node
    when Nokogiri::XML::Element
      attrs = node.attribute_nodes.sort_by(&:name).map { |a| %( #{a.name}="#{squeeze(a.value)}") }.join
      lines << "#{pad}<#{node.name}#{attrs}>"
      node.children.each { |c| walk(c, depth + 1, lines) }
    when Nokogiri::XML::Text, Nokogiri::XML::CDATA
      text = squeeze(node.text)
      lines << "#{pad}#{text}" unless text.empty?
    when Nokogiri::XML::Comment
      lines << "#{pad}<!-- #{squeeze(node.text)} -->"
    end
  end

  def squeeze(str)
    str.gsub(/\s+/, ' ').strip
  end
end
