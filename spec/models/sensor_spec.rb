require 'spec_helper'

describe Sensor do
  let(:sensor) { Fabricate(:sensor, {
    :manufacturer => 'LND',
    :model => '7317',
    :serial_number => '12345',
    :measurement_type => 'alpha',
    :measurement_category => 'radiation'
  })}

  subject { sensor }

  its(:manufacturer)          { should == 'LND' }
  its(:model)                 { should == '7317' }
  its(:serial_number)         { should == '12345' }
  its(:measurement_type)      { should == 'alpha' }
  its(:measurement_category)  { should == 'radiation' }
end
