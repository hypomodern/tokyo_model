require 'core'
##
# TokyoModel::Base; a base class -- your models should inherit from this. There will be connection and query methods,
# as well as a server pool and index management methods on the class.
module TokyoModel
  class Base
    include TokyoModel::Core
    
    ADAPTERS = {
      :rufus_tokyo => "tokyo_model_rufus_tokyo_adapter",
      :rufus_edo => "tokyo_model_rufus_edo_adapter",
      :native => "tokyo_model_native_adapter",
      :mikio => "tokyo_model_native_adapter",
      :acts_as_flinn => "tokyo_model_ruby_tokyotyrant_adapter",
      :ruby_tokyotyrant => "tokyo_model_ruby_tokyotyrant_adapter"
    }
    
    def initialize
      @new_record = true
      @record = {}
    end
    
    def new_record?
      @new_record || false
    end
  
    def valid_field?(field_name)
      fields = self.class.tokyo_model_options[:filter_fields]
      if fields.nil? || fields.include?(field_name.to_sym)
        return true
      end
      false
    end
  
    def write_field(field_name, value)
      record[field_name] = value
    end
  
    def read_field(field_name)
      record[field_name]
    end
    
  end
end