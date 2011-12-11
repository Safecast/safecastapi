require 'spec_helper'

describe Group do
  let(:group) { Fabricate(:group, {
    :description    => 'Measurements around Fukushima',
  })}
  subject { group }
  
  its(:description)   { should == 'Measurements around Fukushima' }

end
