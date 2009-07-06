require 'abstract_adapter'
require 'tokyo_tyrant'

module TokyoModel
  class Base
    class << self
      def configure_adapter(klass)
        TokyoModel::Adapters::RubyTokyoTyrantAdapter.new(klass)
      end
    end
  end
end

module TokyoModel
  module Adapters
    class RubyTokyoTyrantAdapter < AbstractAdapter
      def initialize(klass)
        super(klass)
      end
      
      def query(conditions, options)
        merge_options = default_options.merge(options)
        fanout = merge_options.delete(:fanout)
        aggregate = merge_options.delete(:aggregate)
        raw = merge_options.delete(:raw)
        pk_only = merge_options.delete(:pk_only)
        order_by = merge_options.delete(:order)
        
        connect do |tyrant|
          if conditions.is_a?(Hash)
            # a complex query, then
            query = tyrant.prepare_query do |q|
              conditions.each do |condition|
                q.condition(parse_condition(condition))
              end
              q.limit(merge_options(:limit)) unless merge_options(:limit)
              q.order_by(parse_ordering(order_by)) unless order_by
            end
            
            results = pk_only ? query.search : query.get
            results = package(results) unless raw
          elsif conditions.is_a?(Array)
            # looking for a set of responses
            results = tyrant.mget(conditions)
            results = package(results) unless raw
          else
            # looking just for a PK, then
            results = tyrant[conditions]
            results = package(results) unless raw
          end
        end

      end # /query
    end
  end
end