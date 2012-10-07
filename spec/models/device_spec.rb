require 'spec_helper'

describe Device do
  let(:sensor) { Fabricate(:sensor, {
    :manufacturer => 'LND',
    :model => '712',
    :measurement_type => 'alpha beta gamma',
    :measurement_category => 'radiation'
  })}

  let(:device) { Fabricate(:device, {
    :manufacturer     => 'Safecast',
    :model            => 'iGeigie',
    :sensors          => [sensor]
  })}

  subject { device }

  its(:manufacturer)    { should == 'Safecast' }
  its(:model)           { should == 'iGeigie' }
  its(:sensors)         { should include(sensor) }
end
