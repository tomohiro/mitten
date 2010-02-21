require 'nokogiri'

class GoogleProfile < Mitten::Plugin
  def initialize(*args)
    super

    @suffix = @config['suffix'] || 'のプロフィールが知りたい'
    @limit  = @config['limit'] || 3
  end

  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+?)#{@suffix}/
      get_profile($1).each { |profile| notice(channel, profile) }
    end
  end

  private

  def get_profile(target)
    profiles = []
    uri = URI.escape("http://www.google.com/profiles?q=#{target}")
    result = Nokogiri::HTML(Kconv.toutf8(open(uri).read))/'div.profile-result'

    unless result.count == 0
      result[0...@limit].each do |profile|
        detail = profile.at('div.profile-result-text-block').text
        uri = URI.short("http://www.google.com#{profile.at('a')['href']}")

        profiles << "#{detail} (#{uri})"
      end
    else
      profiles << 'そんな人いにゃい o(>_<)o'
    end
    profiles
  end
end
