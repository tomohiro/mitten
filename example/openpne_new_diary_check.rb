require 'sdbm'
require 'mechanize'
require 'nokogiri'

=begin

 ex. environment.yaml

  OpenPNENewDiaryCheck:
    sleep: 60
    channel: '#Mitten@freenode'
    uri : 'http://openpne.example.com'
    username: 'username'
    password: 'password'

=end
class OpenPNENewDiaryCheck < Mitten::Plugin
  def initialize(*args)
    super

    @uri      = @config['uri']
    @username = @config['username']
    @password = @config['password']
  end

  def before_hook
    login
  end

  def login
    @agent = Mechanize.new
    @agent.get(@uri) do |login_page|
      login_page.form_with(:name => 'login') do |f|
        f.username = @username
        f.password = @password
      end.submit
    end
  end

  def main
    begin
      db = SDBM.open("/tmp/openpnenewdiarycheck_#{@username}.db")
      diary_page = @agent.get "#{@uri}/?m=pc&a=page_h_diary_list_all"
      diaries = Nokogiri::HTML(diary_page.body)/'div.item'

      diaries[1...diaries.size].each do |diary|
        uri = "#{@uri}/#{(diary/'td.photo/a').first.attributes['href']}"
        redo if uri == nil or uri == ''

        unless db.include? uri
          db[uri] = '1'
          nick  = ((diary/'td').to_a)[1].text.gsub(/ \(.*\)$/, '')
          title = ((diary/'td').to_a)[2].text.gsub(/ \([0-9].?\)/, '')
          message = "#{nick}さんが「#{title}」を投稿しました！ (#{uri})"

          @channels.each do |channel|
            notice(channel, message)
            sleep 5
          end
        end
      end
    ensure
      db.close
    end
  end
end
