require 'ostruct'
require 'yaml'

class TimeCall < Mint::Plugin
  def initialize(*args)
    super

    @config_file = @config['config']
  end

  def before_hook
    @call_list = load_config
  end

  def load_config
    OpenStruct.new(File.open(@config_file) { |f| YAML.load(f) }).time
  end

  def notify
    now = Time.now.strftime('%H%M').to_i
    @channels.each do |channel|
      notice(channel, @call_list[now]) if @call_list[now]
    end
  end
end
