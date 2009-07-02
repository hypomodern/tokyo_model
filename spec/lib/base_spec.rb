require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::Base do
  it "should exist" do
    lambda { TokyoModel::Base }.should_not raise_error
  end
  
  describe "tokyo_store" do
    it "should provide some sane defaults" do
      Modell.tokyo_model_options.should include(
        :type => :db,
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
  end
end