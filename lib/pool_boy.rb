module TokyoModel
  # The Pool Boy serves the Tokyo Model by managing the pool, obviously.
  # PoolBoy contains simple methods for getting connectable objects in and out of the class pool.
  # It will have more to do once we start enabling aggregate and fanout queries.
  class PoolBoy    
    attr_accessor :pool
    def initialize(pool)
      @pool = pool
    end
    
    # acquire_server picks the first server from the pool, or a named server if a name is provided
    # +name+: might be +nil+ (pick the first server), +:all+ (pick all the servers), or a list of servers to get
    def acquire_servers(names = nil)
      connection_spec = nil
      if names.nil? || (names.is_a?(Array) && names.empty?)
        [objectify(pool.first)]
      elsif names == :all
        pool.map { |server| objectify(server) }
      else
        names.map do |name|
          if pool.is_a?(Hash)
            connection_spec = pool[name]
            connection_spec ||= name if pool.values.include?(name)
          else
            connection_spec = name if pool.include?(name)
          end
          raise(TokyoModel::ServerNotInPool, "Requested '#{name}', but this server isn't in the pool ('#{pool.join("', '")}')") unless connection_spec
          objectify(connection_spec)
        end
      end
    end
    
    ##
    # In an ironic twist, the pool boy objectifies its charges. The cycle continues.
    def objectify(connection)
      Server.new(connection)
    end
    
    class Server
      attr_accessor :host, :port
      def initialize(string)
        parse_server_options(string)
      end
      
      def parse_server_options(string)
        options = string.split(":")
        self.host = options.first
        self.port = options[1].to_i || 0
      end
    end
  end
end