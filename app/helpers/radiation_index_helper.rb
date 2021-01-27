# frozen_string_literal: true

module RadiationIndexHelper
  def rindex_nav_button(index)
    active = if params[:index].blank?
               index == :average
             else
               params[:index] == index.to_s
             end
    content_tag(:button, style: 'background-color: #f5f5f5; color: black', class: "btn btn-secondary #{active ? 'active' : ' '}") do
      p = get_pd_params(index)
      link_to t(index.to_s), p, { style: 'color: grey;' }
    end
  end

  def get_pd_params(index)
    params.to_unsafe_h.except(:action, :controller).merge(index: (index unless index == :average))
  end

  def rindex_nav_li(index) # rubocop:disable Metrics/AbcSize
    active = if params[:index].blank?
               index == :average
             else
               params[:index] == index.to_s
             end
    content_tag(:li, class: ('active' if active)) do
      p = params.to_unsafe_h.except(:action, :controller).merge(index: (index unless index == :average))
      p[:page] = nil unless active
      link_to t(index.to_s), p
    end
  end
end
