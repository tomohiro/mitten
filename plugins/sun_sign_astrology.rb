require 'nkf'

require 'open-uri'
require 'nokogiri'

class SunSignAstrology < Mint::Plugin
  def initialize(*args)
    super
    @suffix = @config['suffix'] || 'の運勢教えて'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+)#{@suffix}$/
      result = search_sign($1)

      if result == nil
        notice(channel, '／(^o^)＼ わかにゃいっ') 
      else 
        notice(channel, result) 
      end
    end
  end

  private

  def search_sign(sign)
    ranking = get_ranking 'http://fortune.yahoo.co.jp/12astro/ranking.html'
    result = ''

    ranking.each do |rank|
      if rank[:name].to_s == sign
        result = "#{rank[:name]} #{rank[:rank]} #{rank[:desc]}！だよ♪  (#{rank[:link]})"
      end
    end
    result
  end

  def get_ranking(uri)
    begin
      doc = Nokogiri::HTML(open(uri).read)

      names = doc/'td/p/img'
      ranks = doc/'td/img'
      descs = doc/'p.ft01/a'

      ranking = []
      names.each_with_index do |name, desc_counter|
        rank_counter = desc_counter + 1
        ranking << {
          :name => name.attributes['alt'],
          :rank => ranks[rank_counter].attributes['alt'],
          :desc => descs[desc_counter].text,
          :link => descs[desc_counter].attributes['href']
        }
      end

      ranking
    rescue
      '／(^o^)＼ こわれたっ'
    end
  end
end
