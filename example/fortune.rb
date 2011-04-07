require 'open-uri'
require 'nokogiri'

class Fortune < Mitten::Plugin
  def initialize(*args)
    super

    @sex = {
      :male   => 'http://legacy.fortune.yahoo.co.jp/fortune/bin/omikuji?sex=m',
      :female => 'http://legacy.fortune.yahoo.co.jp/fortune/bin/omikuji?sex=f'
    }
    @prefix = @config['prefix'] || 'おみくじ'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^#{@prefix}/
      notice(channel, read_fortune)
    end
  end

  private

  def read_fortune
    html = Nokogiri::HTML(open(@sex.values.choice).read)
    fortunes = {}
    message  = ''

    (html/'table/tr/td').each do |content|
      if content.inner_text =~ /^今日のあなたの(.+?)は(.+?)。/
        fortunes[$1] = $2
      end
    end

    fortunes.reverse_each do |genre, fortune|
      message << "#{genre}：#{fortune}　"
    end
    "今日のあなたは #{message}こんな感じだよ♪"
  end
end
