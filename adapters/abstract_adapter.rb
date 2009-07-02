##
# Abstract Adapter contains baseline functionality common to all the adapter subclasses
module TokyoModel
  module Adapters
    class AbstractAdapter
      def adapter_name
        "Abstract"
      end
      
      def fetch_pool(for_class)
        for_class.tokyo_model_options[:pool] || []
      end
      
      def stringify(object)
        object.to_s
      end
    end
  end
end