require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::QueryResult do
  before(:each) do
    @zero_results = TokyoModel::QueryResult.new({}, Modell)
    @results_from_mget = TokyoModel::QueryResult.new({
      Modell.tokyo_model_options[:pool].first => { "1235" => { "column" => "value" }, "1236" => { "column" => "new_value" } }
    }, Modell)
    @results_from_query = TokyoModel::QueryResult.new({
      Modell.tokyo_model_options[:pool].first => [ { "column" => "value", :__id => "1235" }, { "column" => "new_value", :__id => "1236" } ]
    }, Modell)
    @fanout_results_from_query = TokyoModel::QueryResult.new({
      Modell.tokyo_model_options[:pool].first => [ { "column" => "value", :__id => "1235" } ],
      "some_other_server" => [ { "column" => "value", :__id => "1235" } ]
    }, Modell)
    @results_with_errors = TokyoModel::QueryResult.new({
      Modell.tokyo_model_options[:pool].first => [ { "column" => "value", :__id => "1235" } ],
      "some_other_server" => StandardError.new("I had an error")
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
          "1235" => { "column" => "value" },
          "1236" => { "column" => "new_value" }
        }
      }
    end
    it "should handle query_result style arrays" do
      @results_from_query.raw.should == {
        Modell.tokyo_model_options[:pool].first => {
          "1235" => { "column" => "value" },
          "1236" => { "column" => "new_value" }
        }
      }
    end
    it "should cache the results of this operation in an instance variable" do
      tmp = @fanout_results_from_query.send(:parse_results)
      @fanout_results_from_query.should_receive(:parse_results).once.and_return(tmp)
      @fanout_results_from_query.raw
      @fanout_results_from_query.raw
    end
  end
  
  describe "errors" do
    it "should be set to a hash of server => error message if any errors occurred" do
      @results_with_errors.errors.keys.should include("some_other_server")
      @results_with_errors.errors["some_other_server"].should be_a_kind_of(StandardError)
    end
    it "should be an empty hash otherwise" do
      @results_from_mget.errors.should == {}
    end
  end
  
  describe "errors?" do
    it "should be a simple boolean shortcut for the errors method" do
      @results_with_errors.errors?.should be_true
      @results_from_mget.errors?.should be_false
    end
  end
  
  describe "servers_by_key" do
    it "should reorganize the results into a hash of primary_key => [server, server]" do
      @results_from_query.servers_by_key.should == {
        "1235" => [Modell.tokyo_model_options[:pool].first],
        "1236" => [Modell.tokyo_model_options[:pool].first]
      }
    end
    it "should return an empty hash if that's all we've got" do
      @zero_results.servers_by_key.should == {}
    end
    it "should correctly handle multiple results" do
      @fanout_results_from_query.servers_by_key.should == {
        "1235" => ["some_other_server", Modell.tokyo_model_options[:pool].first]
      }
    end
    it "should not place items that are errors into this hash" do
      @results_with_errors.servers_by_key.should == { "1235" => ["/tmp/tokyo_model_table.tct_sock"] }
    end
    it "should cache the results of this operation in an instance variable" do
      tmp = @fanout_results_from_query.raw
      @fanout_results_from_query.should_receive(:raw).and_return(tmp)
      @fanout_results_from_query.servers_by_key
      @fanout_results_from_query.servers_by_key
    end
  end
  
  describe "objects" do
    it "should convert the results into TokyoModel objects!" do
      @results_from_query.objects.each { |obj| obj.should be_a_kind_of(Modell) }
      @results_from_query.objects.size.should == 2
    end
    it "the objects should have their private @__servers property set" do
      @results_from_query.objects.each do |obj|
        obj.instance_variable_get(:@__servers).should == [Modell.tokyo_model_options[:pool].first]
      end
    end
    it "should not have a problem with result sets that have errors" do
      @results_with_errors.objects.size.should == 1
      @results_with_errors.objects.each { |obj| obj.should be_a_kind_of(Modell) }
    end
    it "should return an empty array if there are no results" do
      @zero_results.objects.should == []
    end
  end
  
  describe "count" do
    it "should return a count of all the unique pks found" do
      @results_from_query.count.should == 2
    end
    it "should return 0 if there are no results" do
      @zero_results.count.should == 0
    end
  end
end