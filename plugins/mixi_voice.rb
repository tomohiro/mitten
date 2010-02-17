require 'uri'
require 'mechanize'
require 'nokogiri'

=begin

 ex. environment.yaml

  MixiVoice:
    sleep: 60
    channel: '#Mint@freenode'
    email: 'email'
    password: 'password'

=end
class MixiVoice < Mint::Plugin
  MIXI_LOGIN_URI   = 'http://mixi.jp'
  RECENT_VOICE_URI = MIXI_LOGIN_URI + '/recent_echo.pl'

  def initialize(*args)
    super

    @email    = @config['email']
    @password = @config['password']

    @agent = WWW::Mechanize.new
    if ENV['http_proxy']
      proxy = URI.parse(ENV['http_proxy'])
      @agent.set_proxy(proxy.host, proxy.port)
    end

    @caches = []
  end

  def before_hook
    login
  end

  def main
    get_voice
  end

  def login
    @agent.get MIXI_LOGIN_URI do |login_page|
      login_page.form 'login_form' do |form|
        form.email = @email
        form.password = @password
      end.submit
    end
  end

  def get_voice
    voices = crawl_recent_voice
    voices.sort.each do |key, voice|
      if @caches.empty? or !@caches.has_key? key
        @channels.each do |channel|
          message(channel, "[#{voice[:nickname]}]#{voice[:reply]} #{voice[:comment]}")
          sleep 5
        end
      end
    end
    @caches = voices
  end

  def crawl_recent_voice
    recent_page = @agent.get RECENT_VOICE_URI
    voices = {}

    (Nokogiri::HTML(recent_page.body)/'td.comment').each do |comment|
      key = timestamp(comment)
      voices[key] = build_voice(comment)
    end
    voices
  end

  def timestamp(comment)
    comment.at('div.echo_post_time').text
  end

  def build_voice(comment)
    {
      :member_id => comment.at('div.echo_member_id').text,
      :post_time => comment.at('div.echo_post_time').text,
      :nickname  => comment.at('div.echo_nickname').text,
      :reply     => ((' ' + comment.at('a').text) if comment.at('a').text =~ /^>/),
      :comment   => comment.at('div.echo_body').text
    }
  end
end
