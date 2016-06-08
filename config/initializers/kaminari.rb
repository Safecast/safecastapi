module Kaminari
  module ActionViewExtension
    def paginate_without_count(scope, options = {}, &_block)
      options[:total_pages] = scope.current_page
      options[:total_pages] += 1 if scope.length == scope.limit_value

      paginator = Kaminari::Helpers::PaginatorWithoutCount.new(self, options.reverse_merge(current_page: scope.current_page, per_page: scope.limit_value, remote: false))
      paginator.to_s
    end
  end

  module Helpers
    class PaginatorWithoutCount < Paginator
    end
  end
end
