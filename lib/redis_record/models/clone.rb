module RedisRecord
  class Clone < RedisRecord::Base
    attribute :name, String
    attribute :description, String

    attribute :sample_id, Integer

    belongs_to :sample
  end
end