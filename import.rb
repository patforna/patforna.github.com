require 'rubygems'
require 'nokogiri'
require 'fileutils'
require 'date'

# usage: ruby import.rb my-blog.xml
# my-blog.xml is a file from Settings -> Basic -> Export in blogger.

data = File.read ARGV[0]
doc = Nokogiri::XML(data)

@posts = {}

def add(node)
  id = node.search('id').first.content
  type = node.search('category').first.attr('term').split('#').last  
  case type
  when 'post'
    @posts[id] = Post.new(node)
  when 'template', 'settings'
  else
     # ignore
  end
end

def write(post)
  puts "writing #{post.file_name}"
  File.open(File.join('_posts', post.file_name), 'w') do |file|
    file.write post.header
    file.write "\n\n"
    file.write "<div class='post'>\n"
    file.write post.content
    file.write "\n</div>\n"
  end
end

class Post
  attr_reader :comments
  def initialize(node)
    @node = node
    @comments = []
  end

  def add_comment(comment)
    @comments.unshift comment
  end

  def title
    @node.search('title').first.content
  end
  
  def tags
    @node.xpath('.//ns:category[@scheme="http://www.blogger.com/atom/ns#"]', 'ns' => 'http://www.w3.org/2005/Atom').map{|x| x.attr('term')}
  end

  def content
    @node.search('content').first.content
  end

  def creation_date
    creation_datetime.strftime("%Y-%m-%d")
  end

  def creation_datetime
    Date.parse(@node.search('published').first.content)
  end

  def file_name
    param_name = title.split(/[^a-zA-Z0-9]+/).join('-').downcase
    %{#{creation_date}-#{param_name}.html}
  end

  def header
    [
      '---',
      %{layout: post},
      %{title: "#{title}"},
      %{date: #{creation_datetime}},
      %{tags: #{tags}},      
      %{comments: false},
      '---',
      '{% include JB/setup %}'
    ].join("\n")
  end
end

class Comment
  def initialize(node)
    @node = node
  end

  def author
    @node.search('author name').first.content
  end

  def content
    @node.search('content').first.content
  end
end

entries = {} 

doc.search('entry').each do |entry|
  add entry
end

FileUtils.rm_rf('_posts')
Dir.mkdir("_posts") unless File.directory?("_posts")

@posts.each do |id, post|
  write post
end