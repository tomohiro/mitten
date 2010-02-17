class Sample < Mint::Plugin
  def initialize(config, socket)
    super(config, socket)
  end

  def main
    @channels.each { |channel| post(NOTICE, channel, Time.now.to_s) }
  end
end
