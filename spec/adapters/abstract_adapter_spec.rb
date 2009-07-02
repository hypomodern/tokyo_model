require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::Adapters::AbstractAdapter do
  before(:each) do
    @adapter = TokyoModel::Adapters::AbstractAdapter.new
  end
  
  it_should_behave_like "an adapter that implements AbstractAdapter"
end