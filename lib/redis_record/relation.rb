require 'redis_record/relation/finder_methods'
require 'redis_record/relation/query_methods'

module RedisRecord
  class Relation < Object
    include Enumerable

    include RedisRecord::FinderMethods
    include RedisRecord::QueryMethods

    delegate :[], :each, :to => :to_a

    attr_reader :model
    attr_accessor :records

    def initialize(model)
      @loaded = false
      @model = model
    end

    def initialize_copy(model)
      reset
      self
    end

    def reset
      @loaded = nil
      @records = []
    end

    def loaded?
      @loaded
    end

    def to_a
      return @records if loaded?

      request = build_where_request
      response = self.model.connection.send(request)

      raise Exception.new(response['error']) if response['success'] == false

      if response['nodes'].nil? || response['nodes'].empty?
        @records = []
      else
        @records = response['nodes'].compact.map do |object|
          record = self.model.new(ActiveSupport::JSON.decode(object).symbolize_keys!)
          record.run_callbacks :find
          record
        end
      end

      @loaded = true
      @records
    end

    def reload
      reset
      to_a
      self
    end

    def delete(id_or_array)
      id_or_array = [id_or_array].flatten
      self.model.connection.send("delete #{self.model.table_name} #{id_or_array.to_s}")
      true
    end

    def destroy_all
      each do |r|
        r.destroy
      end

      true
    end

    def to_s
      "<#{self.class.to_s}: #{@model.model_name}>"
    end
  end
end