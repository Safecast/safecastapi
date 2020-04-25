# frozen_string_literal: true

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
      p = params.permit!.except(:action, :controller).merge(by_status: (status unless status == :all))
      p[:page] = nil unless active
      link_to t("bgeigie_imports.states.#{status}"), bgeigie_imports_url(p)
    end
  end

  def status_details(bgeigie_import)
    bgeigie_import.status_details.each_with_object([]) do |(k, v), a|
      a << t(".#{k}") if v
    end
  end

  def operation_button(bgeigie_import, action, text = t(format('.%<action>s', action: action)))
    form_for bgeigie_import, url: { action: action } do |f|
      f.submit text, class: 'btn btn-primary'
    end
  end

  def unmoderated_id_list(bgeigie_imports)
    bgeigie_imports.each_with_object([]) do |import, import_url_list|
      import_url_list << bgeigie_import_path(import) unless import.approved? || import.rejected?
    end
  end

  def moderator?(user)
    user.try!(:moderator?)
  end

  def tilemap_link(bgeigie_import)
    link_to 'Map View', "https://safecast.org/tilemap/?logids=#{bgeigie_import.id}", target: '_blank', class: 'btn btn-primary', style: 'color: #fff'
  end

  def ok_remove_tag
    style = 'pull-right'
    style += block_given? && yield ? ' icon-ok' : ' icon-remove'
    content_tag(:i, '', class: style)
  end
end
