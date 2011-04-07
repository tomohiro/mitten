require 'open-uri'
require 'nokogiri'

class Gasoline < Mitten::Plugin
  def initialize(*args)
    super

    @suffix = @config['suffix'] || 'ガソリンいくら'
    @base_uri = 'http://gogo.gs'
    @rank_uri = @base_uri + '/rank/result/?pref=47&ws=&p_mode=0&mm=0&service%5B3%5D=3&desd=0&x=24&y=17'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^#{@suffix}$/
      gasoline_ranking.each do |gs|
        notice(channel, gs) 
      end
    end
  end

  private

  def gasoline_ranking
    ranking = []

    begin
      lists = Nokogiri::HTML(open(@rank_uri).read, nil, 'EUC-JP')/'.tableType02'/'tr'
      lists[2..6].each do |line|
        next unless line.at('td[@colspan="5"]').nil?

        rank    = line.at('.crownBig001').text
        price   = line.at('.priceLevelBig5').text
        station = line.at('strong').text
        address = line.at('small').text
        detail  = URI.short(@base_uri + line.at('strong/a').attributes['href'])

        ranking << "#{rank}位 #{price}円 #{station} #{address} (#{detail})"
      end
    rescue Exception => e
      ranking << 'こわれたっ／(^o^)＼'
    end

    ranking
  end
end
