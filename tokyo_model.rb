##
# Tokyo Model, a lightweight abstraction for records stored in Tokyo Tyrant Tables
lib_path = File.expand_path( File.join(File.dirname(__FILE__), "lib") )
$LOAD_PATH.unshift lib_path unless $LOAD_PATH.include?(lib_path)

adapter_path = File.expand_path( File.join(File.dirname(__FILE__), "adapters") )
$LOAD_PATH.unshift adapter_path unless $LOAD_PATH.include?(adapter_path)

require 'rubygems'
# Load Rails-ported core extensions
Dir.glob(File.join(lib_path, "core_ext", "*.rb")).each do |core_ext|
  require core_ext
end
require 'base'
require 'core'

module TokyoModel
  class InvalidAdapter < StandardError
    def initialize(msg)
      temp_msg = "Unknown driver #{msg}. Known drivers are #{TokyoModel::Base::ADAPTERS.keys.join(", ")}."
      super(temp_msg)
    end
  end
end