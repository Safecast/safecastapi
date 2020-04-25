# frozen_string_literal: true

module RadiationIndexHelper
  def rindex_nav_li(index) # rubocop:disable Metrics/AbcSize
    active = if params[:index].blank?
               index == :average
             else
               params[:index] == index.to_s
             end
    content_tag(:li, class: ('active' if active)) do
      p = params.permit!.except(:action, :controller).merge(index: (index unless index == :average))
      p[:page] = nil unless active
      link_to t(index.to_s), p
    end
  end
end
