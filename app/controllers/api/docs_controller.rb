class Api::DocsController < Api::ApplicationController
  respond_to :html

  layout 'api_doc'

  def index
    redirect_to api_doc_path(:overview)
  end

  def show
    #look for filename /app/views/api/docs/markdown/:id.md
    md_root = "#{Rails.root}/app/views/api/docs/markdown"

    #default to en-US locale
    params[:locale] ||= 'en-US'

    md_path = "#{md_root}/#{params[:locale]}/#{params[:id]}.md"

    if File.directory? md_root and File.exists? md_path
      md_file = File.open md_path
    else
      md_file = File.open "#{md_root}/en-US/invalid.md"
    end

    @content = md_file.read
  end

  def show_resource
    md_root = "#{Rails.root}/app/views/api/docs/markdown"
    md_path = "#{md_root}/#{params[:locale]}/resources/#{params[:id]}.md" if params.has_key? :locale

    if File.directory? md_root and File.exists? md_path
      md_file = File.open md_path
    else
      md_file = File.open "#{md_root}/en-US/invalid.md"
    end

    @content = md_file.read
  end

end
