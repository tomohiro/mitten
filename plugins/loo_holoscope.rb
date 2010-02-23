require 'nkf'

require 'open-uri'
require 'nokogiri'

class LooHoloscope < Mitten::Plugin
  def initialize(*args)
    super

    @suffix = @config['suffix'] || 'の運勢教えて'
    @signs = {
      'おひつじ座' => 'http://lou5.jp/uranai/aries/',
      'おうし座'   => 'http://lou5.jp/uranai/taurus/',
      'ふたご座'   => 'http://lou5.jp/uranai/gemini/',
      'かに座'     => 'http://lou5.jp/uranai/cancer/',
      'しし座'     => 'http://lou5.jp/uranai/leo/',
      'おとめ座'   => 'http://lou5.jp/uranai/virgo/',
      'てんびん座' => 'http://lou5.jp/uranai/libra/',
      'さそり座'   => 'http://lou5.jp/uranai/scorpio/',
      'いて座'     => 'http://lou5.jp/uranai/sagittarius/',
      'やぎ座'     => 'http://lou5.jp/uranai/capricorn/',
      'みずがめ座' => 'http://lou5.jp/uranai/aquarius/',
      'うお座'     => 'http://lou5.jp/uranai/pisces/',
    }
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+)#{@suffix}$/
      result = get_result(@signs[$1])

      if result == nil
        notice(channel, '／(^o^)＼ わかにゃいっ') 
      else 
        notice(channel, result) 
      end
    end
  end

  private

  def get_result(uri)
    begin
      doc = Nokogiri::HTML(open(uri).read)

      loo = (doc/'div.box-inner/p').first.text.gsub("\n", '') + ' ってルーさんが言ってたよ♪'
    rescue Exception => e
      e.to_s
    end
  end
end
