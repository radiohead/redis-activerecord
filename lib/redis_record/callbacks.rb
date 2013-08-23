require 'active_support/concern'

module RedisRecord
  module Callbacks
    extend ActiveSupport::Concern

    included do
      extend ActiveModel::Callbacks

      define_model_callbacks :initialize, :find, :only => [:after, ]
      define_model_callbacks :create, :save, :destroy
    end

    def save
      run_callbacks(:save) { super }
    end

    def destroy
      run_callbacks(:destroy) { super }
    end
  end
end