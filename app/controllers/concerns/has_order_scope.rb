# frozen_string_literal: true

module HasOrderScope
  extend ActiveSupport::Concern

  VALID_SORT_ORDERS = %w(asc desc).freeze

  included do
    has_scope :order do |_controller, scope, value|
      _column_name, sort_order = value.split(' ', 2)

      sort_order = sort_order.to_s.strip.downcase || 'asc'
      if VALID_SORT_ORDERS.include?(sort_order)
        # TODO: Use `nulls_last` Arel method in Rails 6.1
        scope.order("#{value} NULLS LAST")
      end
    end
  end
end
