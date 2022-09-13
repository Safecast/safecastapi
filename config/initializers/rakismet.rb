# frozen_string_literal: true

Safecast::Application.config.rakismet.key = ENV.fetch('AKISMET_API_KEY', nil)
Safecast::Application.config.rakismet.url = "https://#{ENV.fetch('DEFAULT_HOSTNAME', nil)}/"
