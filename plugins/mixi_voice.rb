require 'uri'
require 'mechanize'
require 'nokogiri'

=begin

 ex. environment.yaml

  MixiVoice:
    sleep: 60
    channel: '#Mitten@freenode'
    email: 'email'
    password: 'password'

=end
class MixiVoice < Mitten::Plugin
  MIXI_LOGIN_URI   = 'http://mixi.jp'
  RECENT_VOICE_URI = MIXI_LOGIN_URI + '/recent_echo.pl'

  def initialize(*args)
    super

    @email    = @config['email']
    @password = @config['password']
    @nickname = @config['nickname']

    @agent = Mechanize.new
    if ENV['http_proxy']
      proxy = URI.parse(ENV['http_proxy'])
      @agent.set_proxy(proxy.host, proxy.port)
    end

    @caches = []
  end

  def before_hook
    login
    @identity = get_identity
  end

  def login
    @agent.get MIXI_LOGIN_URI do |login_page|
      login_page.form 'login_form' do |form|
        form.email = @email
        form.password = @password
      end.submit
    end
  end

  def on_privmsg(prefix, channel, message)
    if prefix =~ Regexp.new(@nickname)
      case message
      when /^re ([0-9]+) (.+)/
        reply(channel, $1, $2)
      when /^rm ([0-9]+)/
        delete($1)
      when /^add (.+)/
        add($1)
      end
    end
  end

  def main
    get
  end

  def get
    voices = crawl_recent_voice
    voices.sort.each do |key, voice|
      if @caches.empty? or !@caches.has_key? key
        @channels.each do |channel|
          notice(channel, "mixi voice: [#{voice[:nickname]}]#{voice[:reply]} #{voice[:comment]} (#{key})")
          sleep 5
        end
      end
    end
    @caches = voices
  end

  def get_identity
    recent_page = @agent.get RECENT_VOICE_URI
    identity = (Nokogiri::HTML(recent_page.body)/'input#post_key').first['value']
  end

  def reply(channel, key, voice)
    if @caches.has_key? key
      member_id = @caches[key][:member_id]
      post_time = @caches[key][:post_time]

      @agent.get RECENT_VOICE_URI do |post_page|
        post_page.form_with(:action => '/add_echo.pl') do |form|
          form.body = voice
          form.parent_member_id = member_id
          form.parent_post_time = post_time
        end.submit
      end
    else
      notice(channel, '指定された返信先が見つかりません')
    end
  end

  def delete(post_time)
    @agent.post "http://mixi.jp/delete_echo.pl?post_time=#{post_time}&post_key=#{@identity}&redirect=recent_echo"
    @caches = crawl_recent_voice
  end

  def add(voice)
    @agent.get RECENT_VOICE_URI do |post_page|
      post_page.form_with(:action => 'add_echo.pl') do |form|
        form.body = voice
      end.submit
    end
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
