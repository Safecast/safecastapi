# frozen_string_literal: true

# TODO: get this from running region

Aws::Rails.add_action_mailer_delivery_method(:aws_sdk, region: 'us-west-2')
