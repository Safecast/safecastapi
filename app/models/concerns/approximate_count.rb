# frozen_string_literal: true

module ApproximateCount
  extend ActiveSupport::Concern

  module ClassMethods
    def approximate_count
      count_by_sql("SELECT reltuples FROM pg_class WHERE relname = '#{table_name}'")
    end
  end
end
