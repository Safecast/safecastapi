module BgeigieImportsHelper

  def bgeigie_nav_li(status)
    active = if params[:by_status].blank?
      status == nil
    else
      params[:by_status] == status.to_s
    end
    content_tag(:li, :class => ('active' if active)) do
      link_to t("bgeigie_states.#{status}"),
              bgeigie_imports_url(:by_status => status)
    end
  end

end
