require 'redis_record/associations/generic_association'

module RedisRecord
  module Associations
    class HasOneAssociation < GenericAssociation
      def create_accessor(klass)
        klass.class_eval <<-RUBY_EVAL
          def #{@target}
            #{@target.classify}.where(:#{klass.model_name.demodulize.downcase}_id => id)
          end
        RUBY_EVAL

        klass.class_eval <<-RUBY_EVAL
          def #{@target}=(other)
            # Set old relation key to nil
            old_relation = self.#{@target}

            unless old_relation.nil?
              old_relation.#{klass.model_name.demodulize.downcase}_id = nil
              old_relation.save
            end

            # Add new relation
            other.#{klass.model_name.demodulize.downcase}_id = id
            other.save
          end
        RUBY_EVAL
      end
    end
  end
end