module DocsHelper

  def api_example(url_method, *args)
    json_args = args.collect { |h| (h.is_a?(Hash) ? h.merge(:format => :json, :locale => nil) : h)}
    json_args = [{:format => :json}] if json_args.empty?
    json_url = send(url_method, *json_args)
    url = send(url_method, *args)
    render :partial => 'layouts/api_example', :locals => {
      :json_url => json_url,
      :url => url
    }
  end

end