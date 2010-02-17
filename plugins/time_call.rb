require 'ostruct'
require 'yaml'

class TimeCall < Mint::Plugin
  def initialize(config, socket)
    super(config, socket)

    @config_file = config['config']
  end

  def before_hook
    @call_list = load_config
  end

  def main
    now = "#{Time.now.hour}#{Time.now.min}".to_i
    @channels.each do |channel|
      notice(channel, @call_list[now]) if @call_list[now]
    end
  end

  def load_config
    OpenStruct.new(File.open(@config_file) { |f| YAML.load(f) }).time
  end
end
