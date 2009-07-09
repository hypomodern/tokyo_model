##
# Abstract Adapter contains baseline functionality common to all the adapter subclasses
module TokyoModel
  module Adapters
    class AbstractAdapter
      attr_accessor :plug
      def initialize(klass)
        @plug = klass
      end
      
      def adapter_name
        "Abstract"
      end
      
      def fetch_pool
        plug.tokyo_model_options[:pool] || []
      end
      
      def default_options
        {
          :pk_only => false,
          :limit => nil,
          :order => nil,
          :servers => :all
        }
      end
      
      def primary_key
        :__id
      end
      
      def stringify(object)
        object.to_s
      end
      
      def hash?
        plug.tokyo_model_options[:use] == :hash
      end
      
      def table?
        plug.tokyo_model_options[:use] == :db
      end
      
      def pool_boy
        plug.server_pool
      end
      
      def parse_condition(condition)
        condition
      end
      
      def parse_ordering(order)
        order
      end
      
      def package(result_list)
        result_list = [result_list] unless result_list.is_a?(Array)
        
        result_list = result_list.map do |hash|
          plug.setup(hash.delete(self.primary_key), hash)
        end
        result_list.size < 2 ? result_list.first : result_list
      end
      
      def connect(options = {}, &blk)
        if options[:persist]
          raise TokyoModel::NotImplementedYet
          #persistent_connection(options)
        else
          servers = pool_boy.acquire_servers(options[:servers])
          
          threads = {}
          servers.each do |server|
            threads["#{server.host}#{server.port == 0 ? '' : ":" + server.port}"] = Thread.new do
              tyrant = tyrant_class.new(server.host, server.port)
              thread_result = blk.call(tyrant)
              tyrant.close
              thread_result
            end
          end
          threads.inject({}) do |all_results, (server, t)|
            t.join
            thread_response = nil
            begin
              thread_response = t.value
            rescue => e
              thread_response = e
            end
            all_results.merge!(server => thread_response)
            all_results
          end
        end
      end
      
      private
      def tyrant_class
        TokyoModel::Adapters::AbstractAdapter::AbstractTyrant
      end
      
      class AbstractTyrant
        def close
          true
        end
      end
    end
  end
end