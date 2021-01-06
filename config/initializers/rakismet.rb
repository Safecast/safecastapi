# frozen_string_literal: true

Safecast::Application.config.rakismet.key = ENV['AKISMET_API_KEY']
Safecast::Application.config.rakismet.url = 'http://safecast.com/'
