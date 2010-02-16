require 'mechanize'
require 'nokogiri'

class OpenPNENewDiaryCheck < Mint::Plugin
  def initialize(config, socket)
    super(config, socket)

    @sleep    = config['sleep'] || 60
    @uri      = config['uri']
    @username = config['username']
    @password = config['password']
    @diaries = {}

    login
  end

  def run
    loop do
      check_diaries
      sleep @sleep
    end
  end

  def login
    @agent = WWW::Mechanize.new
    @agent.get(@uri) do |login_page|
      login_page.form_with(:name => 'login') do |f|
        f.username = @username
        f.password = @password
      end.submit
    end
  end

  def check_diaries 
    diary_page = @agent.get "#{@uri}/?m=pc&a=page_h_diary_list_all"
    diaries = Nokogiri::HTML(diary_page.body)/'div.item'

    diaries[1...diaries.size].each do |diary|
      uri = "#{@uri}/#{(diary/'td.photo/a').first.attributes['href']}"

      redo if uri == nil or uri == ''

      nick  = ((diary/'td').to_a)[1].text.gsub(/ \(.*\)$/, '')
      title = ((diary/'td').to_a)[2].text.gsub(/ \([0-9].?\)/, '')

      message = "#{nick}さんが「#{title}」を投稿しました！ (#{uri})"

      unless @diaries.has_key? uri
        @diaries[uri] = message
        post(NOTICE, @channel, message) if @diaries.size > 20
      end
    end
  end
end
