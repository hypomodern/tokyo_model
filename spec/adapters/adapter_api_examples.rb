##
# This spec endeavors to ensure that the given Adapter conforms to the public API for adapters
shared_examples_for("a concrete adapter") do
  it "must implement core methods" do
    [:query, :set_index, :connect, :increment, :decrement, :save].each do |meth|
      @adapter.should respond_to(meth)
    end
  end
end