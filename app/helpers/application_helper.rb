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
end
