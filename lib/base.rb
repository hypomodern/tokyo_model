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
      @__servers = []
      @record = {}
      @primary_key = nil
    end
    
    def self.setup(pk, record, servers = [])
      new_model = allocate
      new_model.instance_variable_set(:@record, record.symbolize_keys)
      new_model.instance_variable_set(:@primary_key, pk)
      new_model.instance_variable_set(:@__servers, servers)
      new_model
    end
    
    # == #find
    # 
    # find returns a TokyoModel::QueryResult proxy, which is pretty easy to work with.
    #
    # find options
    # * +:servers+: a list of servers to narrow the search to.
    # * +:pk_only+: a boolean indicating whether or not to return the raw result hash or a TokyoModel object. Default = +false+
    # * +:order+: which column to order results on
    # * +:limit+: how many results to return. Pass an array of [limit, offset] if you want an offset
    #
    # Examples
    # Modell.find("1235") # => check all servers in pool for that primary_key
    # Modell.find("1235", { :servers => ["archive_1"] } ) # => check 'archive_1'
    # Modell.find({ :policy_id => '1243' }) # => collect all results from all servers
    # Modell.find({ :policy_id => '1243' }, { :pk_only => true }) # => collect all pks from all servers
    # Modell.find({ :policy_id => '1254' }, { :servers => ['archive_2'] }) # check only 'archive_2'
    #
    # Disjoint (or) Queries! n.b. array definitely needed, since +Array#extract_options!+ is trained to look for hashes
    # Modell.find([{ :policy_id => '1243' }, { :policy_id => '1337' }])
    def self.find(*ids_or_search)
      options = ids_or_search.extract_options! if ids_or_search.size > 1
      options ||= {}
      queries = ids_or_search.flatten
      
      # check for serial-queries
      if queries.first.is_a?(Hash)
        serial_querier(queries, options)
      else
        query(queries, options)
      end
    end
    
    def self.set_index(column, type)
      adapter.set_index(column, type)
    end
    
    def new_record?
      @new_record || false
    end
    
    def increment(column, value)
      self.class.adapter.increment(column, value)
    end
    
    def decrement(column, value)
      self.class.adapter.decrement(column, value)
    end
    
    def save(*servers)
      if self.id.nil?
        raise TokyoModel::NoPrimaryKey
      end
      new_record? ? create(servers) : update(servers)
    end
    
    def create(servers = [])
      self.class.adapter.save(self.id, self.record, servers)
      @__servers = servers.empty? ? self.class.find(self.id).raw.keys : servers
      @new_record = false
      self
    end
    
    def update(servers = [])
      # combine any *new* servers we want to save to with the previous list of servers
      server_list = servers | @__servers
      self.class.adapter.save(self.id, self.record, server_list)
      self
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