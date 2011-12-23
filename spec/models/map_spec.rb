require 'spec_helper'

describe Map do
  let(:map) { Fabricate(:map, {
    :description    => 'Measurements around Fukushima',
  })}
  subject { map }
  
  its(:description)   { should == 'Measurements around Fukushima' }

end
