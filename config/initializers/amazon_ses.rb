ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => 'AKIAIUP5TO7IEWCLDR7Q',
  :secret_access_key => '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'
  
# ses = AWS::SES::Base.new(:access_key_id     => 'AKIAIUP5TO7IEWCLDR7Q', :secret_access_key => '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')