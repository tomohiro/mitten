require 'nokogiri'

class GoogleWeather < Mitten::Plugin
  def initialize(*args)
    super

    @suffix = @config['suffix'] || 'の天気教えて'
    @indexes = {'今日の' => 0, '明日の' => 1, '明後日の' => 2, '明々後日の' => 3}
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+?の|)(.+?)#{@suffix}/
      option = '今日の'
      option = $1 unless $1 == ''
      keyword = $2

      notice(channel, get_weather(keyword, option))
    end
  end

  private

  def get_weather(keyword, option)
    uri = URI.escape("http://www.google.co.jp/search?q=#{keyword}+週間天気")
    html = Nokogiri::HTML(Kconv.toutf8(open(uri).read))

    city = (html/'h3.r/b').first.text
    weather = ((html/'div[@align="center"]')/'img')[@indexes[option]]['title']  
    temperature = ((html/'div[@align="center"]')/'nobr')[@indexes[option]].text

    "#{option}#{city}の天気は #{weather} だよっ [#{temperature}] (#{URI.short(uri)})"
  end
end
