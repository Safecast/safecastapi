module ApplicationHelper
  def link_to_switch_locale
    if params[:locale] == "en-US"
      link_to "JA", :locale => "ja"
    else
      link_to "EN", :locale => "en-US"
    end
  end

  # taken from Railscast #207, syntax highlighting with markdown.
  # Currently unused, but will be used as docs get fleshed out.
  class HTMLwithPygments < Redcarpet::Render::HTML
    def block_code(code, language)
      sha = Digest::SHA1.hexdigest(code)
      Rails.cache.fetch ['code', language, sha].join('-') do
        Pygments.highlight(code, lexer: language)
      end
    end
  end

  def markdown(text)
    renderer = HTMLwithPygments.new(hard_wrap: true, filter_html: true)
    options = {
      autolink: true,
      no_intra_emphasis: true,
      fenced_code_blocks: true,
      lax_html_blocks: true,
      strikethrough: true,
      superscript: true
    }
    Redcarpet::Markdown.new(renderer, options).render(text).html_safe
  end

  def current_page_api_example(url)
    render :partial => 'layouts/current_page_api_example', :locals => {:url => url}
  end

  def human_label(model_name, attr_name)
    I18n.t(
      "activerecord.attributes.#{model_name}.#{attr_name}_tooltip",
      :default => t("activerecord.attributes.#{model_name}.#{attr_name}")
    )
  end

  def datetime_picker(model_name, attr_name)
    render :partial => 'layouts/datetime_picker', :locals => {
      :model_name => model_name,
      :attr_name => attr_name
    }
  end

  def filter_field(model_name, attr_name, options = {})
    render :partial => 'layouts/filter_field', :locals => {
      :model_name => model_name,
      :attr_name => attr_name,
      :options => options
    }
  end

  def filter_tag(model_name, attr_name)
    render :partial => 'layouts/filter_tag', :locals => {
      :model_name => model_name,
      :attr_name => attr_name
    }
  end

  def summarize_results(collection)
    render :partial => 'layouts/summarize_results', :locals => {
      :collection => collection
    }
  end

  def show_filters(model_name, attr_names)
    render :partial => 'layouts/show_filters', :locals => {
      :model_name => model_name,
      :attr_names => attr_names
    }
  end
end