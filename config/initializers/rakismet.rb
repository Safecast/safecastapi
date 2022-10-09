# frozen_string_literal: true

Safecast::Application.config.rakismet.test = Rails.env.test?
Safecast::Application.config.rakismet.key = ENV.fetch('AKISMET_API_KEY', '_key_')
Safecast::Application.config.rakismet.url = "https://#{ENV.fetch('DEFAULT_HOSTNAME', nil)}/"
