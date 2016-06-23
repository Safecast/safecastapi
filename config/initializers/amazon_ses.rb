ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
                                       :access_key_id     => Configurable.aws_access_key_id,
                                       :secret_access_key => Configurable.aws_secret_access_key
  
