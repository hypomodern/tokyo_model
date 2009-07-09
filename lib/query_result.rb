module TokyoModel
  # Take a set of query results, which is likely to be a hash of +{ "server_name" => [results] }+
  # and convert it to an intermediate form, from which further transformations and information
  # is available
  #
  # For instance:
  # result = Modell.find({ :policy_id => "12" }) # => TokyoModel::QueryResult
  # result.errors? # => hopefully +false+
  # result.count
  # result.objects # => a list of +TokyoModel+s
  # result.raw # => the raw hash of results
  # result.keys_by_server # => reformat the results into { "1235" => ["server_1", "server_2"] } format
  # result.count # => how many unique records were found (across all servers)
  class QueryResult
    attr_accessor :object_class
    def initialize(results, klass)
      @__raw_results = results
      @object_class = klass
    end
    
    def raw
      @raw ||= parse_results
    end
    
    def errors
      @errors ||= raw.inject({}) do |accum, (server, result)|
        accum[server] = result if result.is_a?(StandardError)
        accum
      end
    end
    
    def errors?
      !errors.empty?
    end
    
    def servers_by_key
      @servers_by_key ||= raw.inject({}) do |accum, (server, result)|
        if result.is_a?(Hash)
          pks = result.keys
          pks.each do |pk|
            accum[pk] ||= []
            accum[pk] = accum[pk] | [server]
          end
        end
        accum
      end
    end
    
    def objects
      @objects ||= servers_by_key.inject([]) do |accum, (pk, server_list)|
        record = raw[server_list.first][pk]
        if record
          accum << object_class.setup(pk, record, server_list)
        end
        accum
      end
    end
    
    def count
      servers_by_key.keys.length
    end
    
    private
    def parse_results
      @__raw_results.inject({}) do |raw, (server, results)|
        if results.is_a?(Hash)
          raw.merge(server => results)
        elsif results.is_a?(Array)
          pk_looks_like = object_class.adapter.primary_key
          formatted = results.inject({}) do |new_results, hsh|
            pk = hsh.delete(pk_looks_like)
            new_results[pk] = hsh if pk
            new_results
          end
          raw.merge(server => formatted)
        else
          raw.merge(server => results)
        end
      end
    end
  end
end