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
  # result.keys_and_servers # => reformat the results into { "1235" => ["server_1", "server_2"] } format
  class QueryResult
    attr_accessor :object_class
    def initialize(results, klass)
      @__raw_results = results
      @object_class = klass
    end
    
    def raw
      return @raw if @raw
      parse_results
    end
    
    private
    def parse_results
      @raw = @__raw_results.inject({}) do |raw, (server, results)|
        if results.is_a?(Hash)
          raw.merge(server => results)
        else
          pk_looks_like = object_class.adapter.primary_key
          formatted = results.inject({}) do |new_results, hsh|
            pk = hsh.delete(pk_looks_like)
            new_results[pk] = hsh if pk
            new_results
          end
          raw.merge(server => formatted)
        end
      end
    end
  end
end