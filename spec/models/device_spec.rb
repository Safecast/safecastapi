require 'spec_helper'

RSpec.describe Device, type: :model do
  let(:device) { Fabricate(:device, {
    :manufacturer     => 'Safecast',
    :model            => 'iGeigie',
    :sensor           => 'LND-712'
  })}

  subject { device }

  its(:manufacturer)    { should == 'Safecast' }
  its(:model)           { should == 'iGeigie' }
  its(:sensor)          { should == 'LND-712' }
end
