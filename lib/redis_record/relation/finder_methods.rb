require 'active_support/concern'
require 'active_support/core_ext/object/blank'

require 'redis_record/support/string'
require 'redis_record/support/hash'

module RedisRecord
  module FinderMethods
    attr_writer :where_filters
    def where_filters
      @where_filters ||= {}
    end

    attr_writer :where_params
    def where_params
      @where_params ||= {
        :order => :id,
        :direction => :asc,
        :limit => '',
        :offset => '',
      }
    end

    def where(filters)
      return self if filters.blank?

      relation = clone
      relation.where_filters += build_where(filters)
      relation
    end

    def all(filters = nil)
      filters.nil? ? relation = self : relation = where(filters)
      relation.to_a
    end

    def first(filters = nil)
      filters.nil? ? relation = self : relation = where(filters)

      if loaded?
        @records.first
      else
        relation.limit(1).to_a.first
      end
    end

    def last(filters = nil)
      filters.nil? ? relation = self : relation = where(filters)

      if loaded?
        @records.last
      else
        relation.limit(1).reverse_order.to_a.first
      end
    end

    def reverse_order
      relation = clone

      if relation.where_params[:direction].eql?(:desc)
        relation.where_params += {:direction => :asc}
      else
        relation.where_params += {:direction => :desc}
      end

      relation
    end

    private
      def build_where(filters)
        case filters
        when String
          parse_filter_string(filters)
        when Hash
          parse_filter_hash(filters)
        else
          {}
        end
      end

      def build_order(order)
        raise Exception.new('Wrong params for order, should be String!') unless order.is_a?(String)
        
        field, direction = order.split[0..2].map{ |o| o.downcase.to_sym }
        raise Exception.new("Wrong ordering direction: #{direction}") unless [:desc, :asc].include?(direction)

        {:order => field, :direction => direction}
      end

      def build_limit(limit)
        {:limit => limit.to_s}
      end

      def build_offset(offset)
        {:offset => offset.to_s}
      end

      def build_where_request
        return "find #{self.model.table_name} all #{self.where_filters.to_json} #{self.where_params.to_json}"
      end

      # TODO: fix variable names, organize code
      def parse_filter_string(string)
        hash = {}
        
        x = string.strip.split(/[\s]+&&[\s]+/i)
        t = x.map{|s| s.match(/^([a-zA-Z0-9_]+)[\s]*(<>|<=>|<=|>=|<|>|=|!=)[\s]*(.+)$/i).to_a}.compact

        t.each do |v|
          key, operator, value = v[1..3]
          value.tr!("'", "")
          value.tr!('"', "")

          if value.start_with?('[') && value.end_with?(']')
            value = value.tr('[]', '').split(',').map!{ |s| s.strip }
          end

          value = [value, ] unless value.is_a?(Array)
          value.map! do |s|
            if s.is_number?
              s.to_i
            elsif s.is_float?
              s.to_f
            else
              s
            end
          end

          hash.merge!({ key.to_sym => [operator, value] })
        end

        hash
      end

      def parse_filter_hash(hash)
        hash.reduce({ }){ |memo, v| memo.merge!(v.first => ['=', v.last.is_a?(Array) ? v.last : [v.last]]) }
      end
  end
end