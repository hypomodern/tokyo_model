require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::Adapters::RubyTokyoTyrantAdapter do
  before(:each) do
    @adapter = TokyoModel::Adapters::RubyTokyoTyrantAdapter.new(Modell)
  end
  it_should_behave_like "an adapter that implements AbstractAdapter"
  it_should_behave_like "a concrete adapter"
end