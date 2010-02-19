require 'open-uri'
require 'nokogiri'

class Nanapi < Mint::Plugin
  def initialize(*args)
    super
    @suffix = @config['suffix'] || 'テクニック教えて'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+)#{@suffix}$/
      result = search_technique($1)

      if result == nil
        notice(channel, '／(^o^)＼ わかにゃいっ') 
      else 
        notice(channel, result.to_s) 
      end
    end
  end

  private

  def search_technique(keyword)
    doc = Nokogiri::XML(open("http://nanapi.jp/search/keyword:#{URI.encode(keyword)}/feed.rss").read)
    item = (doc/'item').to_a.choice
    
    "#{item.at('title').text} - #{URI.short(item.at('link').text)}" if item
  end
end
