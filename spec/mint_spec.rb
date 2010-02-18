require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Mint" do
  before(:all) do
    @mint = Mint::Core.new
  end

  it 'Mint::Core Instantiation' do
    @mint.class.should == Mint::Core
  end
end
