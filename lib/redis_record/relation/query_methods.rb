module RedisRecord
  module QueryMethods
    def order(order)
      relation = clone
      relation.where_params += build_order(order)

      relation
    end

    def limit(limit)
      return self unless limit.is_a?(Fixnum)

      relation = clone
      relation.where_params += build_limit(limit)

      relation
    end

    def offset(offset)
      return self unless offset.is_a?(Fixnum)

      relation = clone
      relation.where_params += build_offset(offset)

      relation
    end 
  end  
end