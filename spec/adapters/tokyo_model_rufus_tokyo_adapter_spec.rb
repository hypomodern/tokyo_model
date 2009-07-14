require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class RufusModell < TokyoModel::Base
  tokyo_store :adapter => :rufus_tokyo,
              :pool => [ "/tmp/rufus_tokyo_test_sock" ]
end

describe TokyoModel::Adapters::RufusTokyoAdapter do
  before(:each) do
    @adapter = TokyoModel::Adapters::RufusTokyoAdapter.new(RufusModell)
    
    @dummy_table = mock(Rufus::Tokyo::TyrantTable)
    $tyrant_class = Rufus::Tokyo::TyrantTable
    
    @search_results = [
      {
        :pk => "1608",
        "qbert" => "no",
        "zzix" => "yes"
      },
      {
        :pk => "1609",
        "qbert" => "yes",
        "zzix" => "no"
      },
      {
        :pk => "1610",
        "qbert" => "yes",
        "zzix" => "maybe"
      }
    ]
  end
  it_should_behave_like "an adapter that implements AbstractAdapter"
  it_should_behave_like "a concrete adapter"
end