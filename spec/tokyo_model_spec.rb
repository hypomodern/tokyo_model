require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe TokyoModel do
  it "should exist" do
    lambda { TokyoModel }.should_not raise_error
  end
  
  describe "Custom Errors" do
    it "should have a custom InvalidAdapter error" do
      lambda { TokyoModel::InvalidAdapter }.should_not raise_error
      TokyoModel::InvalidAdapter.new(:wooble).to_s.should =~ /^Unknown driver wooble. Known drivers are/
    end
  end
end