require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::QueryResult do
  before(:each) do
    @zero_results = TokyoModel::QueryResult.new({}, Modell)
    @results_from_mget = TokyoModel::QueryResult.new({
      Modell.tokyo_model_options[:pool].first => { "1235" => { "column" => "value" } }
    }, Modell)
    @results_from_query = TokyoModel::QueryResult.new({
      Modell.tokyo_model_options[:pool].first => [ { "column" => "value", :__id => "1235" } ]
    }, Modell)
  end
  it "should exist" do
    lambda { TokyoModel::QueryResult }.should_not raise_error
  end
  
  describe "initialization" do
    it "should take a group of results and a TokyoModel class and store them for later use" do
      @zero_results.object_class.should == Modell
      @zero_results.raw.should == {}
    end
    
    it "should beat the results into a consistent internal representation" do
      @results_from_mget.raw.should == @results_from_query.raw
    end
  end
  
  describe "object_class" do
    it "should return the classname of the TokyoModel descendent that these results can be transformed into" do
      @zero_results.object_class.should == Modell
    end
  end
  
  describe "raw" do
    it "should return the massaged query results" do
      @zero_results.raw.should == {}
    end
    it "should handle mget-style arrays" do
      @results_from_mget.raw.should == {
        Modell.tokyo_model_options[:pool].first => {
          "1235" => { "column" => "value" }
        }
      }
    end
    it "should handle query_result style arrays" do
      @results_from_query.raw.should == {
        Modell.tokyo_model_options[:pool].first => {
          "1235" => { "column" => "value" }
        }
      }
    end
  end
end