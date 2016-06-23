module DocsHelper
  def api_example_urls(url_method, *args)
    json_args = args.collect { |h| (h.is_a?(Hash) ? h.merge(format: :json, locale: nil) : h) }
    if json_args.empty? || json_args.select { |h| h.is_a?(Hash) }.none?
      (json_args ||= []) << {format: :json, locale: nil}
    end
    json_url = send(url_method, *json_args)
    url = send(url_method, *args)
    [json_url, url]
  end

  def api_example(url_method, *args)
    json_url, url = api_example_urls(url_method, *args)
    render partial: 'layouts/api_example', locals: {
      json_url: json_url,
      url: url
    }
  end

  def api_example_link(http_method, url_method, *args)
    json_path, path = api_example_urls(url_method, *args)
    link_to "#{http_method.to_s.upcase} #{json_path}", path
  end
end