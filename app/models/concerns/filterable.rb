# frozen_string_literal: true

module Filterable
  extend ActiveSupport::Concern

  module ClassMethods
    def filter_params(attributes)
      results = where(nil)
      attributes.each do |key, value|
        results =
          results.public_send(
            "filter_by_attribute",
            key,
            value
          ) if value.present?
      end
      results
    end
  end
end
