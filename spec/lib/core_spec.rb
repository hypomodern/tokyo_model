require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::Core do
  describe "tokyo_store" do
    it "should extend the base class with ClassMethods" do
      [:tokyo_store, :pool, :field_filter].each do |meth|
        Modell.should respond_to(meth)
      end
    end
    it "should extend instances of the base class with InstanceMethods" do
      Modell.send(:included_modules).should include(TokyoModel::Core::InstanceMethods)
    end
    
    it "should set up an adapter attribute on the class" do
      Modell.should respond_to(:adapter)
      Modell.adapter.should be_a_kind_of(TokyoModel::Adapters::RubyTokyoTyrantAdapter)
    end
    
    it "should raise a TokyoModel::InvalidAdapter error if someone specifies a wonky adapter" do
      lambda do
        class BadAdapterSpec < TokyoModel::Base
          tokyo_store :adapter => :qbert
        end
      end.should raise_error(TokyoModel::InvalidAdapter)
    end
    
    it "should raise an error if it cannot locate the adapter file" do
      TokyoModel::Base::ADAPTERS[:invalid_file] = "whats_up_doc_adapter"
      lambda do
        class BadAdapterSpec < TokyoModel::Base
          tokyo_store :adapter => :invalid_file
        end
      end.should raise_error(RuntimeError, "Couldn't locate whats_up_doc_adapter. Is it installed? Is that even the right adapter?")
    end
  end
  
  describe "ModelMethods" do
    it "should delegate core class methods to the adapter" do
      [:query, :connect, :set_index].each do |meth|
        Modell.should respond_to(meth)
        Modell.adapter.should_receive(meth)
        Modell.send(meth)
      end
    end
  end
  
  describe "InstanceMethods" do
    it "should delegate incrementers and saving to the adapter" do
      model = Modell.new
      [:increment, :decrement, :save].each do |meth|
        model.should respond_to(meth)
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