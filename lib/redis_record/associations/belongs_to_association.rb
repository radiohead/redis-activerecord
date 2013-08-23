require 'redis_record/associations/generic_association'

module RedisRecord
  module Associations
    class BelongsToAssociation < GenericAssociation
      def create_accessor(klass)
        klass.class_eval <<-RUBY_EVAL
          def #{@target}
            #{@target.classify}.where(:id => self.#{@target}_id)
          end
        RUBY_EVAL

        klass.class_eval <<-RUBY_EVAL
          def #{@target}=(other)
            self.#{@target}_id = other.id
          end
        RUBY_EVAL
      end

      def add_destroy_hooks(klass)
        # TODO: change Exception class
        raise AttributeError.new 'Invalid option for this type of association'
      end
    end
  end
end