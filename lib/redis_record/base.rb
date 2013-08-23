require 'socket'
require 'virtus'

require 'active_model'
require 'active_support/core_ext/class/attribute'

require 'redis_record/relation'
require 'redis_record/relation/finder_methods'
require 'redis_record/relation/query_methods'

require 'redis_record/connection'

require 'redis_record/associations'
require 'redis_record/persistence'
require 'redis_record/callbacks'

module RedisRecord
  class Base
    include Virtus

    extend ActiveModel::Naming
    extend ActiveModel::Translation

    include ActiveModel::Validations
    include ActiveModel::Conversion
    
    extend RedisRecord::Associations

    include RedisRecord::Persistence
    include RedisRecord::Callbacks

    attribute :id, Integer

    def initialize(attributes = {})
      fields.keys.each do |key|
        send("#{key}=", attributes[key])
      end

      # FIXME: This is a workaround to get `initialize` callbacks working
      # I don't know any proper way to handle this yet.
      run_callbacks :initialize
    end

    def fields=(attrs = {})
      attrs.each do |name, value|
        send("#{name}=", value)
      end
    end

    def fields
      @fields ||= attribute_set.reduce({}){ |memo, atr| memo.merge!({ atr.name => nil }) }
      
      @fields.keys.each{ |key| @fields[key] = send(key) }
      @fields
    end

    # TODO: fix this hack
    before_save :update_timestamps

    def update_timestamps
      if self.fields.include?(:created_at) && self.fields.include?(:updated_at)
        self.created_at = DateTime.now if self.new_record?
        self.updated_at = DateTime.now
      end
    end
    # End TODO

    def to_s
      "<#{self.class.model_name}: id = #{self.id}>"
    end

    def inspect
      "<#{self.class.model_name}: #{self.fields}>"
    end

    class_attribute :connection, :instance_writer => false
    self.connection = Connection.new

    # Class methods
    class << self
      delegate :delete, :destroy, :to => :relation
      delegate :select, :where, :limit, :offset, :order, :to => :relation
      delegate :all, :first, :last, :reload, :to => :relation

      # TODO: fix this hack
      def inherited(klass)
        super
        klass.class_eval <<-RUBY_EVAL
          def self.inherited(klass)
            # Avoid any collisions
            super

            # Get attributes hash
            # { :attribute_name => :attribute_type }
            attributes = klass.attribute_set.reduce({}) do |memo, attr|
              memo.merge!({ attr.name.to_sym => attr.class.to_s.split('::').last })
            end

            klass.connection.send("init " + table_name + " " + attributes.to_json)
          end
        RUBY_EVAL
      end
      # End TODO

      def relation
        @relation ||= Relation.new(self)
      end
    end
  end
end

Dir["#{File.dirname(File.expand_path(__FILE__))}/models/*.rb"].each {|file| require file }
