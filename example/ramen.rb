require 'open-uri'
require 'nokogiri'

class Ramen < Mitten::Plugin
  def initialize(*args)
    super

    @suffix = @config['suffix'] || 'ラーメン食わせろ'
    @base_uri = 'http://ramen.tedaco.net/'
    @rank_uri = @base_uri + 'index.php'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^#{@suffix}/
      notice(channel, shop_choice) 
    end
  end

  def shop_choice
    begin
      list = Nokogiri::HTML(open(@rank_uri).read)/'.access_rank'

      shop = list.to_a.choice
      name = shop.at('a').text
      detail = URI.short(@base_uri + shop.at('a').attributes['href'])

      "#{name} に行けば？ (#{detail})"
    rescue Exception =>e 
      ranking << 'こわれたっ／(^o^)＼'
    end
  end
end
