module Haml::Filters::Code
  include Haml::Filters::Base

  def render(text)
    modified_text = text.gsub(/ /, '&nbsp;')
    modified_text = modified_text.gsub(/\n/, "<br />\n")
  end

end
