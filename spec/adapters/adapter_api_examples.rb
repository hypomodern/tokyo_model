##
# This spec endeavors to ensure that the given Adapter conforms to the public API for adapters
shared_examples_for("a concrete adapter") do
  it "must implement core methods" do
    [:query, :serial_querier, :connect, :increment, :decrement, :save, :set_index].each do |meth|
      @adapter.should respond_to(meth)
    end
  end
  
  it "should reimplement parse_condition and parse_ordering" do
    module TokyoModel
      module Adapters
        class AbstractAdapter
          def parse_condition(*args)
            "Whoops!"
          end
          def parse_ordering(*args)
            "Whoops!"
          end
        end
      end
    end
    @adapter.send(:parse_condition, {"message_id" => "456"}).should_not == "Whoops!"
    @adapter.send( :parse_ordering, "message_id desc" ).should_not == "Whoops!"
  end
  
  describe "save" do
    it "should accept a primary key, record, and a list of servers to save to" do
      lambda { @adapter.save(1235, { "message_id" => "234" }, ["archive_1"]) }.should_not raise_error(ArgumentError)
    end
  end
  
  describe "connect" do
    it "should accept a hash of options" do
      lambda { @adapter.connect({}) {||} }.should_not raise_error(ArgumentError)
    end
  end
  
  describe "call_ext" do
    it "should support calling external (lua) functions" do
      @adapter.should respond_to(:call_ext)
    end
    it "should wrap any failed method invocation in an exception" do
      lambda { @adapter.call_ext("undefined_method", "qq") }.should raise_error(TokyoModel::ExtendedFunctionNotFound)
    end
  end
end