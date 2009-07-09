require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

class Widget; end

describe "Core Extensions" do
  describe "Class" do
    it "should have class attributes" do
      Widget.should respond_to(:cattr_accessor)
    end
    
    it "should have class inheritable attributes" do
      Widget.should respond_to(:class_inheritable_reader)
      Widget.should respond_to(:write_inheritable_attribute)
    end
  end
  
  describe "Array" do
    it "should support popping an options hash off the end" do
      [].should respond_to(:extract_options!)
      [1, 2, { :foe => true }].extract_options!.should == { :foe => true }
    end
    
    it "should support #in_groups_of" do
      integers = (1..25).to_a
      integers.should respond_to(:in_groups_of)
      integers.in_groups_of(5).should include(
        [1,2,3,4,5],
        [6,7,8,9,10],
        [11,12,13,14,15],
        [16,17,18,19,20],
        [21,22,23,24,25]
      )
    end
  end
  
  describe "Hash" do
    describe "key manipulation" do
      it "should support symbolizing keys" do
        { "jones" => "soda", "is" => "weird" }.symbolize_keys.keys.should include(:is, :jones)
      end
      it "should support stringifying keys" do
        { :jones => "soda", :is => "weird" }.stringify_keys.keys.sort.should == ["is", "jones"]
      end
    end
    
    describe "deep_merging" do
      it "should deeply merge hashes" do
        hsh3 = { "server3" => { "1235" => { "column" => "value" } } }
        hsh4 = { "server3" => { "999" => { "column" => "value" } } }
        hsh3.deep_merge(hsh4).should == {"server3"=>{"999"=>{"column"=>"value"}, "1235"=>{"column"=>"value"}}}
      end
      it "should union array values in the hashes" do
        hsh = { "server" => [1,4,5] }
        hsh2 = { "server" => [4, 7, 11], "server2" => [3, 4] }
        hsh.deep_merge(hsh2).should == {"server"=>[1, 4, 5, 7, 11], "server2"=>[3, 4]}
      end
    end
  end
  
  describe "Module" do
    it "should provide a .delegate class method" do
      Widget.should respond_to(:delegate)
    end
    describe "delegate" do
      it "should allow objects to delegate method calls to another source" do
        class FooBarWidget
          def wolfenstein
            "mein shpaghetti code!"
          end
        end
        class Widget
          delegate :wolfenstein, :to => :custom
          def custom
            FooBarWidget.new
          end
        end
        Widget.new.wolfenstein.should == "mein shpaghetti code!"
      end
      it "should allow class instances to delegate method calls to another class instance" do
        class FooBarWidget
          def self.connect
            "ok"
          end
        end
        class Widget
          class << self
            delegate :connect, :to => "FooBarWidget"
          end
        end
        Widget.connect.should == "ok"
      end
    end
    
  end
end