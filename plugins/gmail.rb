require 'net/https'
require 'sdbm'
require 'nokogiri'

=begin

 ex. environment.yaml

  Gmail:
    sleep: 60
    channel: '#Mitten@freenode'
    account: 'account'
    password: 'password'

=end
class Gmail < Mitten::Plugin
  def initialize(*args)
    super

    @account  = @config['account']
    @password = @config['password']

    proxy = ENV['https_proxy'] || ENV['http_proxy']
    if proxy
      @https = Net::HTTP::Proxy(URI.parse(proxy).host, URI.parse(proxy).port).new('mail.google.com', 443)
    else 
      @https = Net::HTTP.new('mail.google.com', 443)
    end

  end

  def before_hook
    login
  end

  def login
    @https.use_ssl = true
    @https.verify_mode = OpenSSL::SSL::VERIFY_NONE
    @request = Net::HTTP::Get.new('/mail/feed/atom')
    @request.basic_auth(@account, @password)
  end

  def main
    begin
      db = SDBM.open("/tmp/#{@account}.db", 0666)
      mail_list = Nokogiri::XML(@https.request(@request).body)
      (mail_list/'entry').each do |entry|
        id = entry.at('id').content
        unless db.include? id
          db[id] = '1'
          title = entry.at('title').text
          name  = entry.at('name').text
          link  = entry.at('link')['href']

          @channels.each do |channel|
            notice(channel, "Gmail: (#{name}) #{title} #{URI.short(link)}")
            sleep 5
          end
        end
      end
    ensure
      db.close
    end
  end
end
