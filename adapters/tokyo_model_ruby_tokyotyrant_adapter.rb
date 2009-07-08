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
      attr_accessor :primary_key
      def initialize(klass)
        super(klass)
        @primary_key = :__id
      end
      
      def query(conditions, options)
        options = default_options.merge(options)
        fanout = options.delete(:fanout)
        aggregate = options.delete(:aggregate)
        raw = options.delete(:raw)
        pk_only = options.delete(:pk_only)
        order_by = options.delete(:order)
        
        results = nil
        connect(:servers => options[:servers]) do |tyrant|
          if conditions.is_a?(Hash)
            # a complex query, then
            query = tyrant.prepare_query do |q|
              conditions.each do |condition|
                q.condition(*parse_condition(condition))
              end
              q.limit(options[:limit]) if options[:limit]
              q.order_by(*parse_ordering(order_by)) if order_by
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
            results[:__id] = conditions if results
            results = package(results) unless raw
          end
        end
        results || nil
      end # /query
      
      def increment(column, value)
        current_value = nil
        connect do |tyrant|
          current_value = tyrant.add_int('column', value)
        end
        { column => current_value }
      end
      
      def decrement(column, value)
        current_value = nil
        connect do |tyrant|
          current_value = tyrant.add_int('column', -value)
        end
        { column => current_value }
      end
      
      def save(pk, record, servers = [])
        connect(:servers => servers) do |tyrant|
          tyrant[pk] = record
        end
      end
      
      def set_index(column, type)
        connect(:servers => :all) do |tyrant|
          tyrant.set_index(column, type)
        end
      end
      
      private
      def tyrant_class
        if table?
          TokyoTyrant::Table
        elsif hash?
          TokyoTyrant::DB
        else
          raise TokyoModel::NotImplmentedYet, "You must specify either hash or table-style storage"
        end
      end
      
      def parse_condition(condition)
        if condition.is_a?(Array)
          if condition.size == 2
            column, value = condition
            operator = value.is_a?(String) ? :streq : :numeq
            [column, operator, value.to_s]
          else
            condition
          end
        else
          # must be a primary key query, e.g. parse_condition("1235")
          operator = condition.is_a?(String) ? :streq : :numeq
          ['', operator, condition.to_s]
        end
      end
      
      def parse_ordering(order)
        if order.is_a?(Array)
          order
        else
          column, order = order.split(" ")
          if order.nil?
            [column]
          else
            order = order == "desc" ? :strdesc : :strasc
            [column, order]
          end
        end
      end
    end
  end
end