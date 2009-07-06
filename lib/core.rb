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
        # avoid multiple inclusion
        return if self.included_modules.include?(TokyoModel::Core::InstanceMethods)
      
        # some friendly default options
        defaults = {
          :adapter => :ruby_tokyotyrant,
          :pool => [],
          :filter_fields => nil,
          :type => :db
        }
      
        tmo = defaults.merge(options)
        # set class-level reader for the options
        class_inheritable_reader :tokyo_model_options
        write_inheritable_attribute :tokyo_model_options, tmo
      
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
          attr_accessor :record
          cattr_accessor :adapter
        end
        send(:include, TokyoModel::Core::InstanceMethods)
        
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
      delegate :query, :set_index, :connect, :to => :adapter, :allow_nil => true
    end
  
    module InstanceMethods
      delegate :increment, :decrement, :save, :to => :@@adapter, :allow_nil => true
      
      def method_missing(method, *args, &block)
        begin
          super(method, *args, &block)
        rescue NoMethodError => e
          field_name = method.to_s.sub(/\=$/, '')
          if valid_field?(field_name)
            if method.to_s =~ /\=$/
              return write_field(field_name.to_sym, args[0])
            else
              return read_field(method)
            end
          end
          raise e
        end
      end
    end
  end
end