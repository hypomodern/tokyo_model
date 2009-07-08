require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::Adapters::AbstractAdapter do
  before(:each) do
    @adapter = TokyoModel::Adapters::AbstractAdapter.new(Modell)
    @dummy_table = mock(TokyoModel::Adapters::AbstractAdapter::AbstractTyrant)
    $tyrant_class = TokyoModel::Adapters::AbstractAdapter::AbstractTyrant
    @search_results = [
      {
        :__id => "1608",
        "qbert" => "no",
        "zzix" => "yes"
      },
      {
        :__id => "1609",
        "qbert" => "yes",
        "zzix" => "no"
      },
      {
        :__id => "1610",
        "qbert" => "yes",
        "zzix" => "maybe"
      }
    ]
  end
  
  it_should_behave_like "an adapter that implements AbstractAdapter"
end