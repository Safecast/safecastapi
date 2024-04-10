# frozen_string_literal: true

Rails.application.configure do
  config.lograge.enabled = true
  config.lograge.formatter = Lograge::Formatters::Json.new

  config.lograge.custom_payload do |controller|
    { forwarded_for: controller.request.headers['X-Forwarded-For'],
      host: controller.request.host,
      parameters: controller.request.filtered_parameters.except(:action, :controller),
      user_agent: controller.request.user_agent,
      user_id: controller.current_user&.id }
  end

  config.lograge.custom_options =
    lambda do |_event|
      { pid: Process.pid, timestmap: Time.now.utc }
    end
end
