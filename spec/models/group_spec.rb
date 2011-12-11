require 'spec_helper'

describe Group do
  let(:group) { Fabricate(:group, {
    :description    => 'Measurements around Fukushima',
    :device_mfg     => 'Medcom',
    :device_model   => 'Inspector',
    :device_sensor  => 'LND-712'
  })}
  subject { group }
  
  its(:description)   { should == 'Measurements around Fukushima' }
  its(:device_mfg)    { should == 'Medcom' }
  its(:device_model)  { should == 'Inspector' }
  its(:device_sensor) { should == 'LND-712' }

end
