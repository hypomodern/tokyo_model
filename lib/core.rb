##
# TokyoModel::Core
# implements everything. It's the core, you see.
module TokyoModel
  module Core
    def self.included(base) # :nodoc: #
      base.extend TokyoModel::Core::ClassMethods
    end
    
    module ClassMethods
      def tokyo_store(options = {})
        # some friendly default options
        defaults = {
          :adapter => :ruby_tokyotyrant,
          :pool => [],
          :filter_fields => nil,
          :use => :db
        }
      
        tmo = defaults.merge(options)
        # set class-level reader for the options
        class_inheritable_reader :tokyo_model_options
        write_inheritable_attribute :tokyo_model_options, tmo
        
        class_inheritable_reader :server_pool
        write_inheritable_attribute :server_pool, TokyoModel::PoolBoy.new(tmo[:pool])
      
        # autorequire the necessary tokyo library
        tokyo_adapter = TokyoModel::Base::ADAPTERS[tmo[:adapter]]
        raise TokyoModel::InvalidAdapter, tmo[:adapter] unless tokyo_adapter
        begin
          require tokyo_adapter
        rescue LoadError
          raise "Couldn't locate #{tokyo_adapter}. Is it installed? Is that even the right adapter?"
        end
      
        # get the basic functionality into the model class
        class_eval do
          extend TokyoModel::Core::ModelMethods
          cattr_accessor :adapter
          attr_accessor :record
          attr_accessor :primary_key
          attr_accessor :__servers
          
          alias_method :id, :primary_key
          alias_method :id=, :primary_key=
        end
        
        self.adapter = configure_adapter(self) # configure_adapter is defined in the individual adapter files.
      end
    
      def field_filter(*fields)
        tokyo_model_options[:filter_fields] = fields
      end
    
      def pool(*server_specs)
        tokyo_model_options[:pool] = server_specs
      end
    end
    
    module ModelMethods
      delegate :query, :serial_querier, :connect, :to => :adapter, :allow_nil => true
    end
  end
end