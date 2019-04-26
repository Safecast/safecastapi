# frozen_string_literal: true

ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
                                       access_key_id: ENV['SES_AWS_ACCESS_KEY_ID'],
                                       secret_access_key: ENV['SES_AWS_SECRET_ACCESS_KEY']
