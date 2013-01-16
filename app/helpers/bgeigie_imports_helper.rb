module BgeigieImportsHelper

  def collect_bgeigie_logs(bgeigie_logs)
    bgeigie_logs.collect do |b|
      point = {
        :lat => b.latitude, 
        :lng => b.longitude,
        :cpm => b.cpm
      }
    end
  end

  def bgeigie_nav_li(status)
    active = if params[:by_status].blank?
      status == nil
    else
      params[:by_status] == status.to_s
    end
    content_tag(:li, :class => ('active' if active)) do
      link_to t("bgeigie_imports.states.#{status}"),
              bgeigie_imports_url(params.merge(:by_status => status))
    end
  end

end
