class Sample < Mint::Plugin
  def initialize(config, socket)
    super(config, socket)
  end

  def main
    @channels.each { |channel| notice(channel, Time.now.to_s) }
  end
end
