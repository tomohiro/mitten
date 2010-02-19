require 'open-uri'
require 'nokogiri'

class GoogleTransit < Mint::Plugin
  def on_privmsg(prefix, channel, message)
    case message
    when /^(.+)から(.+)(へ|まで|に)行.+/
      search_route($1, $2).each { |route| notice(channel, route) }
    end
  end

  private

  def search_route(search_from, search_to)
    from  = URI.escape(search_from.to_u8)
    to    = URI.escape(search_to.to_u8)
    query = "http://maps.google.co.jp/maps?f=q&source=s_q&hl=ja&geocode=&q=from%3A+#{from}+to%3A+#{to}"

    begin
      html = Nokogiri::HTML(open(query).read)
      route = html/'#transit_route_0'

      unless route.empty?
        start_place = (html/'#ddw_addr_area_0/#sxaddr/div.sa').inner_text.to_u8
        end_place   = (html/'#ddw_addr_area_1/#sxaddr/div.sa').inner_text.to_u8
        time = (html/'#transit_route_0').search('span.ts_jtime').inner_text.to_u8
        cost = (html/'#transit_route_0').search('span.ts_routecost').inner_text.to_u8

        messages = ["#{start_place} から #{end_place} へ行くにはね，"]
        messages << "だいたい #{time} で #{cost} ぐらいかかるみたい！"

        (route/'table.ts_step').each_with_index do |step, counter|
          counter += 1
          longline = (step/'span.longline').inner_text.to_u8
          action   = (step/'span.action').inner_text.to_u8

          unless longline.empty?
            locations = step/'span.location'

            messages << "#{counter} : #{action} で「#{longline}」に乗る"
            messages << "　　[発] #{locations[0].inner_text.to_u8}"
            messages << "　　[着] #{locations[1].inner_text.to_u8}"
          else
            location = (step/'span.location').inner_text.to_u8
            messages << "#{counter} : #{location} #{action}"
          end
        end
        messages << "詳しくはここ見てね♪ (#{URI.short(query)})"
      else
        '／(^o^)＼ 迷子！'
      end
    rescue Exception
      '／(^o^)＼ 迷子！'
    end
  end
end
