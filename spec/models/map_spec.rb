require 'spec_helper'

describe Map do
  let(:map) { Fabricate(:map, {
    :name           => 'Fukushima Map',
    :description    => 'Measurements around Fukushima',
  })}
  subject { map }
  
  its(:description)   { should == 'Measurements around Fukushima' }

end
