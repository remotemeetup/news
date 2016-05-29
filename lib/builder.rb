require 'yaml'
require 'erb'
require 'fileutils'
require 'rdiscount'
require 'haml'
require 'json'
require 'awesome_print'

module Greeby

  module Binding
  end

  class Builder

    attr_reader :c, :config

    def initialize
      @root = File.expand_path('../../', __FILE__)
      @news_path = File.join(@root, 'newsletters')
      @views_path = File.join(@root, 'views')
      @pages_path = File.join(@root, 'pages')
      @static_path = File.join(@root, 'site')
      @json_path = File.join(@root, 'json')
      @config = to_ostruct(YAML::load_file(File.join(@root, 'config.yml')))
    end

    def make_letter(source)

      @c = to_ostruct(YAML::load_file(File.join(@news_path, source)))
      @c.edito_html = RDiscount.new(@c.edito.to_s).to_html
      @c.edito_txt = wrap(@c.edito)
      @c.outro_html = RDiscount.new(@c.outro.content.to_s).to_html
      @c.outro_txt = wrap(@c.outro.content)
      @c.signature_html = RDiscount.new(@c.signature.to_s).to_html
      @c.signature_txt = wrap(@c.signature)

      erb = ERB.new(File.read(File.join(@views_path, 'rmn.html.erb')), 0, '<>')
      File.open(File.join(@news_path, 'html', "RMN-#{@c.edition}.html"), 'w') do |f|
        f.puts erb.result(binding)
      end
      txt = ERB.new(File.read(File.join(@views_path, 'rmn.txt.erb')))
      File.open(File.join(@news_path, 'txt', "RMN-#{@c.edition}.txt"), 'w') do |f|
        f.puts txt.result(binding)
      end
      FileUtils.cp(
        File.join(@news_path, 'rmn.yml'),
        File.join(@news_path, 'archives', "rmn-#{@c.edition}.yml")
      )
    end

    def make_archives(source)

      @c = to_ostruct(YAML::load_file(File.join(@news_path, source)))
      @c.edito_html = RDiscount.new(@c.edito.to_s).to_html
      @c.outro_html = RDiscount.new(@c.outro.content.to_s).to_html
      @c.signature_html = RDiscount.new(@c.signature.to_s).to_html

      letters = JSON.parse(File.read(File.join(@static_path, 'editions.json')))
      letters[@c.edition] = { "link" => "rmn-#{@c.edition}.html", "date" => @c.pubdate }
      File.open(File.join(@static_path, 'editions.json'),'w') do |f|
        f.puts letters.to_json
      end

      partial = ERB.new(File.read(File.join(@views_path, "template-#{@c.template}.erb")))
      File.open(File.join(@news_path, 'partials', "RMN-#{@c.edition}.html"), 'w') do |f|
        f.puts partial.result(binding)
      end

      template = File.read(File.join(@views_path, 'static.haml'))
      haml_engine = Haml::Engine.new(template)
      page = OpenStruct.new
      page.name = @c.edition
      page.content = File.read(File.join(@news_path, 'partials', "RMN-#{@c.edition}.html"))
      page.letters = Hash[letters.sort_by { |edition,data| -edition.to_i }]
      page.config = @config
      html = haml_engine.render(page)
      File.open(File.join(@static_path, "rmn-#{page.name}.html"),'w') do |f|
        f.puts html
      end
      File.open(File.join(@static_path, 'index.html'),'w') do |f|
        f.puts html
      end
    end

    def make_all
      letters = JSON.parse(File.read(File.join(@static_path, 'editions.json')))
      letters.each do |letter,c|
        make_archives("archives/rmn-#{letter}.yml")
      end
    end

    def make_web
      template = File.read(File.join(@views_path, 'static.haml'))
      haml_engine = Haml::Engine.new(template)
      pages = Dir.glob(File.join(@pages_path, '*.md'))
      pages.each do |p|
        page = OpenStruct.new
        page.name = File.basename(p, '.md')
        page.content = RDiscount.new(File.read(p)).to_html
        letters = JSON.parse(File.read(File.join(@static_path, 'editions.json')))
        page.letters = Hash[letters.sort_by { |edition,data| -(edition.to_i) }]
        page.config = @config
        html = haml_engine.render(page)
        File.open(File.join(@static_path, "#{page.name}.html"),'w') do |f|
          f.puts html
        end
      end
    end

    def make_rss
      require "rss"
      rss = RSS::Maker.make("2.0") do |maker|
        maker.channel.author = "mose"
        maker.channel.updated = Time.now.to_s
        maker.channel.description = @config.description
        maker.channel.title = @config.title
        maker.channel.link = "#{@config.base_url}/feed.rss"
        maker.channel.language = "en-US"

        letters = JSON.parse(File.read(File.join(@static_path, 'editions.json')))
        partial = ERB.new(File.read(File.join(@views_path, 'rmn.rss.erb')))
        tenletters = Hash[letters.to_a.reverse[0..9]]
        tenletters.each do |letter,c|
          maker.items.new_item do |item|
            item.link = "#{@config.base_url}/#{c['link']}"
            item.guid.content = "#{@config.base_url}/#{c['link']}"
            item.title = "#{@config.title} ##{letter}"
            item.updated = c['date']
            @c = to_ostruct(YAML::load_file(File.join(@news_path, "archives/rmn-#{letter}.yml")))
            item.description = @c.edito
            item.content_encoded = partial.result(binding)
          end
        end
      end
      File.open(File.join(@static_path, "feed.rss"),'w') do |f|
        f.puts rss
      end
    end

    private

    def to_ostruct(obj)
      result = obj
      if result.is_a? Hash
        result = result.dup
        result.each do |key, val|
          result[key] = to_ostruct(val)
        end
        result = OpenStruct.new result
      elsif result.is_a? Array
        result = result.map { |r| to_ostruct(r) }
      end
      return result
    end

    def wrap(s, width=78)
      s.split("\n\n").collect! do |l|
        l.length > width ? l.gsub(/(.{1,#{width}})(\s+|$)/, "\\1\n").strip : l
      end * "\n\n"
    end

  end
end
