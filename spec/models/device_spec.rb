# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Device, type: :model do
  let(:device) do
    Fabricate(:device, manufacturer: 'Safecast',
                       model: 'iGeigie',
                       sensor: 'LND-712')
  end

  subject { device }

  its(:manufacturer)    { should == 'Safecast' }
  its(:model)           { should == 'iGeigie' }
  its(:sensor)          { should == 'LND-712' }
end
