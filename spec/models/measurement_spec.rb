require 'spec_helper'

describe Measurement do
  let(:measurement) { Fabricate(:measurement, {:longitude => 12.001, :latitude => 14.002})}
  subject { measurement }
  
  its(:longitude) { should == 12.001 }
  its(:latitude) { should == 14.002 }
  
end