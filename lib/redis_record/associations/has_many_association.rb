require 'redis_record/associations/generic_association'

module RedisRecord
  module Associations
    class HasManyAssociation < GenericAssociation
      def create_accessor(klass)
        klass.class_eval <<-RUBY_EVAL
          def #{@target}
            #{@target.classify}.where(:#{klass.model_name.demodulize.downcase}_id => self.id)
          end
        RUBY_EVAL

        klass.class_eval <<-RUBY_EVAL
          def #{@target}=(other)
            old_relation = self.#{@target}

            unless old_relation.nil?
              old_relation.each do |rel|
                rel.#{klass.model_name.demodulize.downcase}_id = nil
                rel.save
              end
            end

            if other.respond_to?(:each)
              other.each do |t|
                t.#{klass.model_name.demodulize.downcase}_id = self.id
                t.save
              end
            else
              other.#{klass.model_name.demodulize.downcase}_id = self.id
              other.save
            end
          end
        RUBY_EVAL
      end

      def create_through_accessor(klass)
        klass.class_eval <<-RUBY_EVAL
          def #{@target}
            ids = #{@options[:through]}.map(&:#{@target.singularize}_id)
            #{@target.singularize.capitalize}.where(:id => ids)
          end
        RUBY_EVAL
      end
    end
  end
end