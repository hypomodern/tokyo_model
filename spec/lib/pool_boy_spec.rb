require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe TokyoModel::PoolBoy do
  before(:each) do
    @poolboy = TokyoModel::PoolBoy.new(["/var/ttserver/yargamel", "10.0.100.101:25000", "/var/ttserver/archive/1_message_meta"])
    @poolboy_with_hash = TokyoModel::PoolBoy.new({ "archive_1" => "/var/ttserver/archive/1_message_meta", "archive_2" => "/var/ttserver/archive/2_message_meta"})
  end
  describe "acquire_servers" do
    it "should pick the first server out of the pool if no names are given" do
      chosen_server = @poolboy.acquire_servers.first
      chosen_server.should be_a_kind_of(TokyoModel::PoolBoy::Server)
    end
    it "should pick the first server out of the pool if no names are given" do
      chosen_server = @poolboy.acquire_servers([]).first
      chosen_server.should be_a_kind_of(TokyoModel::PoolBoy::Server)
    end
    
    it "should allow the user to specify a given server by name" do
      chosen_server = @poolboy.acquire_servers("10.0.100.101:25000").first
      chosen_server.should be_a_kind_of(TokyoModel::PoolBoy::Server)
      chosen_server.host.should == "10.0.100.101"
      chosen_server.port.should == 25000
    end
    it "should be able to find a server by a short name if the pool is a hash" do
      chosen_server = @poolboy_with_hash.acquire_servers("archive_1").first
      chosen_server.host.should == "/var/ttserver/archive/1_message_meta"
      chosen_server.port.should == 0
    end
    it "should be able to find a server by the spec even if the pool is a hash" do
      chosen_server = @poolboy_with_hash.acquire_servers("/var/ttserver/archive/2_message_meta").first
      chosen_server.host.should == "/var/ttserver/archive/2_message_meta"
      chosen_server.port.should == 0
    end
    
    it 'should return all servers if :all is requested' do
      chosen_servers = @poolboy.acquire_servers(:all)
      chosen_servers.length.should == 3
      chosen_servers.each do |server|
        server.should be_a_kind_of(TokyoModel::PoolBoy::Server)
      end
    end
    
    it 'should return a list of specified servers if an array is requested' do
      chosen_servers = @poolboy.acquire_servers(["/var/ttserver/yargamel", "10.0.100.101:25000"])
      chosen_servers.length.should == 2
      chosen_servers.each do |server|
        server.should be_a_kind_of(TokyoModel::PoolBoy::Server)
      end
    end
    
    it "should raise a stink if an invalid server is requested" do
      lambda { @poolboy.acquire_servers('Fall Out Boy') }.should raise_error(TokyoModel::ServerNotInPool)
    end
  end
  
  describe "objectify" do
    it "should turn the connection string supplied by the pool into a lightweight object" do
      @poolboy.objectify("/var/ttserver/yargamgel").should be_a_kind_of(TokyoModel::PoolBoy::Server)
    end
  end
  
  
  describe TokyoModel::PoolBoy::Server do
    it "should have a host property" do
      TokyoModel::PoolBoy::Server.new("qbert").host.should == "qbert"
    end
    it "should have a port property" do
      TokyoModel::PoolBoy::Server.new("localhost:5000").port.should == 5000
    end
    
    it "the port property should be 0 by default (to indicate a socket)" do
      @poolboy.objectify("/var/ttserver/yargamel").port.should == 0
    end
    
    describe "parse_server_options" do
      it "should set host and port" do
        str = "127.0.0.1:14001"
        server = TokyoModel::PoolBoy::Server.new(str)
        server.host.should == "127.0.0.1"
        server.port.should == 14001
      end
      it "should set the port to 0 if there isn't one given" do
        str = "/var/ttserver/hoogendyk"
        server = TokyoModel::PoolBoy::Server.new(str)
        server.host.should == "/var/ttserver/hoogendyk"
        server.port.should == 0
      end
    end
  end
end