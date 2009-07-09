require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::Adapters::RubyTokyoTyrantAdapter do
  before(:each) do
    @adapter = TokyoModel::Adapters::RubyTokyoTyrantAdapter.new(Modell)
    
    @dummy_table = mock(TokyoTyrant::Table)
    $tyrant_class = TokyoTyrant::Table
    
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
  it_should_behave_like "a concrete adapter"
  
  ##
  # Should write a separate query test that will work with any adapter and test a wide array of scenarios.
  describe "query" do
    it "simple pk lookup should work out alright" do
      @adapter.should_receive(:connect).and_yield(@dummy_table)
      @dummy_table.should_receive(:mget).with("1608").and_return( Modell.tokyo_model_options[:pool].first => [@search_results.first])
      
      result = @adapter.query("1608", {})
      modell = result.objects.first
      modell.qbert.should == "no"
      modell.id.should == "1608"
      modell.instance_variable_get(:@__servers).should == [Modell.tokyo_model_options[:pool].first]
      modell.should_not be_a_new_record
    end
    it "should work it out alright if you ask for a list of pks" do
      @adapter.should_receive(:connect).and_yield(@dummy_table)
      @dummy_table.should_receive(:mget).with(["1608", "1609", "1610"]).
        and_return( Modell.tokyo_model_options[:pool].first => @search_results)
        
      result = @adapter.query(["1608", "1609", "1610"], {})
      result.servers_by_key.should include(
        "1608" => [Modell.tokyo_model_options[:pool].first],
        "1609" => [Modell.tokyo_model_options[:pool].first],
        "1610" => [Modell.tokyo_model_options[:pool].first]
      )
    end
    it "should handle an actual query pretty well, too" do
      @adapter.should_receive(:connect).and_yield(@dummy_table)
      query = mock(Object)
      @dummy_table.should_receive(:prepare_query).
        and_return( query )
      query.should_receive(:get).and_return(Modell.tokyo_model_options[:pool].first => [@search_results[1], @search_results[2]])
        
      result = @adapter.query({ :qbert => "yes" }, {})
      result.count.should == 2
      result.objects.first.qbert.should == "yes"
    end
  end
  
  describe "tyrant_class" do
    it "should return an appropriate class for the given model" do
      @adapter.send(:tyrant_class).should == TokyoTyrant::Table
      
      TokyoModel::Adapters::RubyTokyoTyrantAdapter.new(DataTable).send(:tyrant_class).should == TokyoTyrant::DB
    end
  end
  
  describe "set_index" do
    it "should tell the library to build (or rebuild) an index of the given type for the given column" do
      TokyoTyrant::Table.should_receive(:new).with("/tmp/tokyo_model_table.tct_sock", 0).and_return(@dummy_table)
      @dummy_table.should_receive(:set_index).with("message_id", :lexical)
      @dummy_table.should_receive(:close)
      
      @adapter.set_index("message_id", :lexical)
    end
  end
  
  describe "save" do
    it "should write the record to the tokyo tyrant" do
      TokyoTyrant::Table.should_receive(:new).with("/tmp/tokyo_model_table.tct_sock", 0).and_return(@dummy_table)
      @dummy_table.should_receive(:[]=).with(1235, { "message_id" => '123adf' }).and_return(true)
      @dummy_table.should_receive(:close).and_return(true)
      
      @adapter.save(1235, { "message_id" => '123adf' }, ['/tmp/tokyo_model_table.tct_sock'])
    end
    it "should write the record to the first pool server if no server in particular is specified" do
      TokyoTyrant::Table.should_receive(:new).with("/tmp/tokyo_model_table.tct_sock", 0).and_return(@dummy_table)
      @dummy_table.should_receive(:[]=).with(1235, { "message_id" => '123adf' }).and_return(true)
      @dummy_table.should_receive(:close).and_return(true)
      
      @adapter.save(1235, { "message_id" => '123adf' })
    end
  end
  
  describe "increment/decrement" do
    before(:all) do
      start_tyrants
    end
    describe "increment" do
      it "should increment an integer value for a given column" do
        model = Modell.new
        model.id = 1235
        model.save
        model.increment("count", 1)["count"].should == 1
        model.increment("count", 10)["count"].should == 11
      end
    end
    describe "decrement" do
      it "should decrement an integer value for a given column" do
        model = Modell.new
        model.id = 1235
        model.save
        model.increment("count", 100)
        model.decrement("count", 10)["count"].should == 90
      end
    end
    after(:all) do
      stop_tyrants
    end
  end
  
  describe "parse_condition" do
    it "should convert the given condition to ruby-tokyotyrant's preferred syntax" do
      @adapter.send(:parse_condition, ["message_id", "67abc12q4"]).should == ['message_id', :streq, "67abc12q4"]
    end
    it "should treat a string as primary key query" do
      @adapter.send(:parse_condition, 1652).should == ['', :numeq, "1652"]
    end
    it "should infer numeric or lexical comparison from the match parameter" do
      @adapter.send(:parse_condition, "1652").should == ['', :streq, "1652"]
    end
    it "should simply pass through an array" do
      @adapter.send(:parse_condition, ["lang", :strinc, "en"]).should == ["lang", :strinc, "en"]
    end
  end
  
  describe "parse_ordering" do
    it "should convert the order condition to ruby-tokyotyrant's preferred syntax" do
      @adapter.send(:parse_ordering, "message_id").should == ['message_id']
    end
    it "should handle various sort orders" do
      @adapter.send(:parse_ordering, "message_id desc").should == ['message_id', :strdesc]
      @adapter.send(:parse_ordering, "message_id asc").should == ['message_id', :strasc]
    end
    it "should simply pass an array through" do
      @adapter.send(:parse_ordering, ["message_id", :strasc]).should == ["message_id", :strasc]
    end
  end
end