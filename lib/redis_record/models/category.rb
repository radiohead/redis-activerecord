module RedisRecord
  class Category < RedisRecord::Base
    attribute :name, String
    attribute :description, String

    has_many :samples
  end
end