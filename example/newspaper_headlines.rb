require 'open-uri'
require 'rss'

class NewspaperHeadlines < Mitten::Plugin
  def initialize(*args)
    super

    @publishers = {
      '琉球新報'       => 'http://rss.ryukyushimpo.jp/rss/ryukyushimpo/index.rdf',
      '沖縄タイムス'   => 'http://www.okinawatimes.co.jp/rss/20/index.xml',
      '読売新聞'       => 'http://rss.yomiuri.co.jp/rss/yol/topstories',
      '毎日新聞'       => 'http://mainichi.jp/rss/etc/flash.rss',
      '日経新聞'       => 'http://www.nikkeibp.co.jp/rss/index.rdf',
      'CNN'            => 'http://headlines.yahoo.co.jp/rss/cnn_c_int.xml',
      '映画ニュース'   => 'http://headlines.yahoo.co.jp/rss/cine.xml',
      'ITMedia'        => 'http://headlines.yahoo.co.jp/rss/itmedia_n.xml',
      'dankogai'       => 'http://blog.livedoor.jp/dankogai/index.rdf',
      'インフルエンザ' => 'http://www3.asahi.com/rss/pandemicflu.rdf'
    }
    @limit = @config['limit'] || 3
  end

  def on_privmsg(prefix, channel, publisher_name)
    if publisher_name == 'ニュースリスト'
      notice(channel, @publishers.keys.join(' / '))
    elsif @publishers.key? publisher_name
      get_headlines(@publishers[publisher_name]).each do |headline|
        notice(channel, headline.to_s)
      end
    end
  end

  private

  def get_headlines(publisher_uri)
    rss = RSS::Parser.parse(open(publisher_uri).read, false)
    rss.items.delete_if { |item| item.title =~ /(AD|PR)/ }

    headlines = [rss.channel.title + ' のニュースだよ！']
    rss.items[0...@limit].each do |item|
      title = item.title
      url   = URI.short(item.link)
      date  = item.date.strftime("%d日 %H:%M")
      headlines << "[#{date}] #{title} (#{url})"
    end
    headlines
  end
end
