require 'redis_record/associations/belongs_to_association'
require 'redis_record/associations/has_one_association'

require 'redis_record/associations/has_many_association'
require 'redis_record/associations/has_and_belongs_to_many_association'

module RedisRecord
  module Associations
    def belongs_to(target, *options)
      build_association(BelongsToAssociation.new(target, options))
    end

    def has_one(target, *options)
      build_association(HasOneAssociation.new(target, options))
    end

    def has_many(target, *options)
      build_association(HasManyAssociation.new(target, options))
    end

    def has_and_belongs_to_many(target, *options)
      raise RuntimeError.new 'Not implemented!'
    end

    private
      def build_association(association)
        association.setup(self)
      end
  end
end