ActionMailer::Base.add_delivery_method :ses, AWS::SES::Base,
  :access_key_id     => '0RTFN5RCBTBSSNWC5782',
  :secret_access_key => 'XmgVAxvObqLexWEM20sd01tRUwJESJ2u8RD3jFgd'
  
# ses = AWS::SES::Base.new(:access_key_id     => '0RTFN5RCBTBSSNWC5782', :secret_access_key => 'XmgVAxvObqLexWEM20sd01tRUwJESJ2u8RD3jFgd')
