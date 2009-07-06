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
end