require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Mitten" do
  before(:all) do
    @mitten = Mitten::Core.new
  end

  it 'Mitten::Core Instantiation' do
    @mitten.class.should == Mitten::Core
  end
end
