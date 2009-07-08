require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::Core do
  describe "tokyo_store" do
    it "should extend the base class with ClassMethods" do
      [:tokyo_store, :pool, :field_filter].each do |meth|
        Modell.should respond_to(meth)
      end
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
    
    it "should setup core attributes on the model" do
      [:primary_key, :record, :__servers, :id].each do |meth|
        lambda { Modell.new.send(meth) }.should_not raise_error
      end
    end
  end
  
  describe "ModelMethods" do
    it "should delegate core class methods to the adapter" do
      [:query, :connect].each do |meth|
        Modell.should respond_to(meth)
        Modell.adapter.should_receive(meth)
        Modell.send(meth)
      end
    end
  end

end