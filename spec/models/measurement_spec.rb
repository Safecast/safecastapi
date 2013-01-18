require 'spec_helper'

describe Measurement do
  context "setting location" do
    let(:measurement) { Fabricate(:measurement, {
      :location => 'POINT(12.001 14.002)'
    })}
    subject { measurement }
    
    its(:longitude) { should == 12.001 }
    its(:latitude) { should == 14.002 }
  end

  context "setting lat and lng" do
    let(:measurement) { Fabricate(:measurement, {
      :longitude => 12.001,
      :latitude =>  14.002
    })}
    subject { measurement }
    
    its(:longitude) { should == 12.001 }
    its(:latitude) { should == 14.002 }
  end
  
end