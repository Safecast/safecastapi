# frozen_string_literal: true

Devise::TokenAuthenticatable.setup do |config|
  config.token_authentication_key = :api_key
end
