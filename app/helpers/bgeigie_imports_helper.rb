module BgeigieImportsHelper
  def collect_bgeigie_logs(bgeigie_logs)
    bgeigie_logs.collect do |b|
      {
        lat: b.latitude,
        lng: b.longitude,
        cpm: b.cpm
      }
    end
  end

  def bgeigie_nav_li(status) # rubocop:disable Metrics/AbcSize
    active = if params[:by_status].blank?
               status == :all
             else
               params[:by_status] == status.to_s
             end
    content_tag(:li, class: ('active' if active)) do
      p = params.merge(by_status: (status unless status == :all))
      p[:page] = nil unless active
      link_to t("bgeigie_imports.states.#{status}"), bgeigie_imports_url(p)
    end
  end

  def status_details(bgeigie_import)
    bgeigie_import.status_details.each_with_object([]) do |(k, v), a|
      a << t(".#{k}") if v
    end
  end

  def operation_button(bgeigie_import, action, text = t(format('.%s', action)))
    form_for bgeigie_import, url: { action: action } do |f|
      f.submit text, class: 'btn btn-primary'
    end
  end

  def get_bgeigie_id_list
    bgeigie_id_list =[]
    @bgeigie_imports.each do |bgeigie_import|
        bgeigie_id_list << bgeigie_import.id unless bgeigie_import.approved?
    end
    return bgeigie_id_list
  end

  def is_moderator?
    @current_user.try!(:moderator?)
  end

end
