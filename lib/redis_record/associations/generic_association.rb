module RedisRecord
  module Associations
    class GenericAssociation
      def initialize(target, *options)
       @target = target.to_s
       @options = options.flatten.extract_options!
      end

      def setup(klass)
        # Create attribute reader/writer
        create_accessor(klass)
        # Insert callbacks for dependent destroying
        add_destroy_hooks(klass) if @options[:dependent]
        # 
        create_through_accessor(klass) if @options[:through]
      end

      def add_destroy_hooks(klass)
        return unless @options[:dependent].eql?(:destroy)

        klass.class_eval <<-RUBY_EVAL
          after_destroy :destroy_dependent_#{@target}

          def destroy_dependent_#{@target}
            #{@target.classify}.where(:#{klass.model_name.demodulize.downcase}_id => self.id).all.destroy_all
          end
        RUBY_EVAL
      end
    end
  end
end