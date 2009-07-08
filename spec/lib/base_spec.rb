require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::Base do
  it "should exist" do
    lambda { TokyoModel::Base }.should_not raise_error
  end
  
  describe "tokyo_store" do
    it "should provide some sane defaults" do
      Modell.tokyo_model_options.should include(
        :use => :db,
        :adapter => :ruby_tokyotyrant,
        :filter_fields => nil
      )
    end
    it "should set our custom options" do
      Modell.tokyo_model_options.should include( :pool => ["/tmp/tokyo_model_table.tct_sock"] )
    end
    it "should load the specified adapter" do
      lambda { TokyoTyrant::Table }.should_not raise_error # because the ruby-tokyotyrant library should have been autoloaded by Modell
    end
    
    it "options given to one model shouldn't effect other TokyoModels" do
      Robot.tokyo_model_options.should_not include( :pool => ["/tmp/tokyo_model_table.tct_sock"] )
      Robot.field_filter(:washington_dc)
      Modell.tokyo_model_options.should include( :filter_fields => nil )
    end
    
    describe "new class methods" do
      it "should include find" do
        Modell.should respond_to(:find)
      end
      it "should alias find as query" do
        Modell.should respond_to(:query)
      end
    end
  end
  
  describe "field_filter" do
    it "should allow you to customize your filtered field list" do
      Modell.field_filter(:qbert, :camping, :zzix)
      Modell.tokyo_model_options.should include(:filter_fields => [:qbert, :camping, :zzix])
    end
  end
  
  describe "pool" do
    it "should allow you to customize your server pool" do
      Modell.pool("/tmp/tt_sock", "/var/tokyo/archive/1")
      Modell.tokyo_model_options.should include(:pool => ["/tmp/tt_sock", "/var/tokyo/archive/1"])
    end
  end
  
  describe "setup" do
    it "should return an instance with the appropriate instance variables set" do
      das = Modell.setup(1235, { "qbert" => "true", "camping" => "no, thanks", "zzix" => "xizz" })
      das.should be_a_kind_of(Modell)
      das.should_not be_a_new_record
      das.primary_key.should == 1235
      das.qbert.should == "true"
      das.record.should include({:qbert=>"true", :camping=>"no, thanks", :zzix=>"xizz"})
    end
  end
  
  describe "InstanceMethods" do
    before(:each) do
      Modell.field_filter(:zagreb)
      @model = Modell.new
    end

    describe "new_record?" do
      it "should return a boolean value indicating whether or not this model has ever been saved" do
        @model.new_record?.should be_a_kind_of(TrueClass)
      end
      it "should be set to true if the model is just instantiated" do
        Modell.new.new_record?.should be_true
      end
      it "should return false by default" do
        Modell.allocate.new_record?.should be_false
      end
    end
    
    describe "save" do
      it "should save the record via the adapter" do
        @model.id = 1235
        Modell.adapter.should_receive(:save).with(1235, {}, [])
        
        @model.save
      end
    end
    
    describe "set_index" do
      it "should set an index via the adapter" do
        Modell.adapter.should_receive(:set_index).with("message_id", :lexical)
        Modell.set_index("message_id", :lexical)
      end
    end
    
    describe "record" do
      it "should contain a hash representing the current object" do
        @model.record.should == {}
      end
      it "can be updated via method_missing hackery" do
        @model.zagreb = "A Prosperous Croat City"
        @model.record.should include(:zagreb => "A Prosperous Croat City")
      end
      it "can be accessed via method_missing hackery" do
        @model.record = { :zagreb => "A Prosperous Croat City" }
        @model.zagreb.should == "A Prosperous Croat City"
      end
      it "can be accessed via method_missing hackery (returning nil if not found)" do
        @model.zagreb.should be_nil
      end
    end
    
    describe "method_missing" do
      it "should check for the method_id amongst the valid fields" do
        Robot.field_filter(:zagreb)
        lambda { Robot.new.zagreb }.should_not raise_error
      end
      
      it "should re-raise NoMethodError if the method_id isn't found amongst the fields" do
        lambda { Robot.new.totally_going_to_fail }.should raise_error(NoMethodError)
      end
    end
  end
end