module ApplicationHelper
  def link_to_switch_locale
    if params[:locale] == "en-US"
      link_to "JA", :locale => "ja"
    else
      link_to "EN", :locale => "en-US"
    end
  end
end
