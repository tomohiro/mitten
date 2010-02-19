require 'nokogiri'

class URIShorten < Mint::Plugin
  def initialize(*args)
    super

    @prefix = @config['prefix'] || 's'
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^#{@prefix} (http:\/\/.+?)$/
      notice(channel, shorten($1))
    end
  end

  private

  def shorten(target)
    uri = URI.escape("http://j.mp/?s=&keyword=&url=#{target}")
    Nokogiri::HTML(open(uri).read).at('#shortened-url')['value']
  end
end
