module RedisRecord
  class Sample < RedisRecord::Base
    attribute :name, String
    attribute :part_number, Integer
    attribute :description, String

    attribute :category_id, Integer

    belongs_to :category
    has_many :clones
  end
end