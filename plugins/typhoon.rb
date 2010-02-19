require "open-uri"
require 'nokogiri'

class Typhoon < Mint::Plugin
  def initialize(*args)
    super

    @uri = 'http://typhoon.yahoo.co.jp/weather/jp/typhoon/typha.html'
    @prefix = @config['prefix'] || '台風どうなった'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^#{@prefix}(.+|)/
      get_typhoon_info.each { |message| notice(channel, message) }
    end
  end

  private

  def get_typhoon_info
    begin
      typhoon_info = []
      doc = Nokogiri::HTML(open(@uri).read, nil, 'EUC-JP')/'tr[@valign="top"]'

      (doc/'td[@widh="60%"]').each do |typhoon|
        typhoon_name = typhoon.inner_html.scan(/<b>(.+)<\/b>/)
        description  = typhoon.inner_text.scan(/ (.+?)。/)

        typhoon_info << "#{typhoon_name} #{description}".to_u8
      end
      typhoon_info << @uri
    rescue
      '／(^o^)＼ こわれたっ'
    end
  end
end
