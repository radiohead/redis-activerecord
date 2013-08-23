require 'active_support/concern'

module RedisRecord
  module Persistence
    extend ActiveSupport::Concern

    def save
      result = self.class.connection.send("set #{self.class.table_name} #{fields.to_json}")
      result["success"] ? (self.id = result["object"]["id"]) : raise(result["error_message"])
      raise(result["error_message"]) unless result["success"]
      result["success"]
    end

    def update_attributes(attrs = {})
      self.fields = attrs
      self.save
    end

    def destroy
      unless new_record?
        self.class.delete(self.id)
        self.freeze
      end
      true
    end

    def new_record?
      self.id.nil?
    end

    module ClassMethods
      def create(attributes)
        record = new(attributes)
        record.run_callbacks(:create) { record.save }
        record
      end

      def table_name
        @table_name ||= model_name.demodulize.downcase.pluralize
      end
    end

  end
end