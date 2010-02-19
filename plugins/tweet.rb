require 'open-uri'
require 'nokogiri'
 
class Tweet < Mint::Plugin
  def on_privmsg(prefix, channel, message)
    if /#{@config['prefix']}/ =~ message
      user = $1
      html = Nokogiri::HTML(open("http://twitter.com/#{user}").read)
 
      tweet = (html/'.entry-content').first
      if !tweet.nil?
        tweet = "@#{user}: #{tweet.text}"
      else
        tweet = (html/'h1.logged-out').first
        if tweet.nil?
          tweet = 'いにゃい／(^o^)＼'
        else
          tweet = tweet.text
        end
      end
      notice(channel, tweet)
    end
  rescue
    notice(channel, 'こわれたっ／(^o^)＼')
  end
end
