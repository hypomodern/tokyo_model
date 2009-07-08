##
# This spec endeavors to ensure that the given adapter conforms to the AbstractAdapter API
shared_examples_for("an adapter that implements AbstractAdapter") do
  it "should respond_to #adapter_name with a string" do
    @adapter.should respond_to(:adapter_name)
    @adapter.adapter_name.should be_a_kind_of(String)
  end
  
  it "should implement fetch_pool and stringify methods" do
    [:fetch_pool, :stringify].each do |meth|
      @adapter.should respond_to(meth)
    end
  end
  
  describe "plug" do
    it "should be a reference to the class it is adapting for" do
      @adapter.should respond_to(:plug)
      @adapter.plug.should_not be_nil
    end
  end
  
  describe "default_options" do
    it "should get the list of options defined on the adapting class" do
      @adapter.should respond_to(:default_options)
      @adapter.default_options.should be_a_kind_of(Hash)
    end
  end
  
  describe "hash or table" do
    it "table? should return true if the model specifies a table" do
      @adapter.table?.should be_true
    end
    it "hash? should return true if the model specifies a hash" do
      @adapter.plug.stub!(:tokyo_model_options).and_return({ :use => :hash })
      
      @adapter.table?.should be_false
      @adapter.hash?.should be_true
    end
  end
  
  describe "pool_boy" do
    it "should be able to get a pool boy from the adapting class" do
      @adapter.pool_boy.should be_a_kind_of(TokyoModel::PoolBoy)
    end
  end
  
  describe "package" do
    it "should package a result list as objects" do
      arr = @adapter.send(:package, @search_results)
      arr.each do |modell|
        modell.should be_a_kind_of(Modell)
      end
      arr.map { |m| m.primary_key }.sort.should == ["1608", "1609", "1610"]
    end
  end
  
  describe "connect" do
    it "should create a basic, self-closing connection that is yielded to the block" do
      $tyrant_class.should_receive(:new).with("/tmp/tokyo_model_table.tct_sock", 0).and_return(@dummy_table)
      @dummy_table.should_receive(:some_library_specific_method)
      @dummy_table.should_receive(:close)
      
      @adapter.connect do |tyr|
        tyr.some_library_specific_method
      end
    end
    it "should connect to a list of servers if a list is provided" do
      fake_tyrant_1 = mock($tyrant_class)
      fake_tyrant_2 = mock($tyrant_class)
      @adapter.pool_boy.should_receive(:acquire_servers).once.with(['archive_1','archive_2']).and_return(
        [mock(Object, :host => "archive_1", :port => 0), mock(Object, :host => "archive_2", :port => 0)])
      $tyrant_class.should_receive(:new).with("archive_1", 0).and_return(fake_tyrant_1)
      $tyrant_class.should_receive(:new).with("archive_2", 0).and_return(fake_tyrant_2)
      fake_tyrant_1.should_receive(:some_library_method)
      fake_tyrant_1.should_receive(:close)
      fake_tyrant_2.should_receive(:some_library_method)
      fake_tyrant_2.should_receive(:close)
      
      @adapter.connect({ :servers => ["archive_1", "archive_2"] }) do |tyr|
        tyr.some_library_method
      end
    end
  end
end