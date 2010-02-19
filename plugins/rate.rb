require 'open-uri'
require 'nokogiri'

class Rate < Mint::Plugin
  def initialize(*args)
    super
    @suffix = @config['suffix'] || '度判定して'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+)#{@suffix}$/
      result = rating($1, prefix.nick)

      if result == nil
        notice(channel, '／(^o^)＼ わかにゃいっ') 
      else 
        notice(channel, result.to_s) 
      end
    end
  end

  private

  def rating(genre, nick)
    uri = "http://kistools.appspot.com/r/#{URI.encode(genre)}/#{nick}"
    doc = Nokogiri::XML(open(uri).read)

    (doc/'table.input_form').first.at('td').text.match(/^(.+)?です。/).to_s.strip + " (#{URI.short(uri)})"
  end
end
