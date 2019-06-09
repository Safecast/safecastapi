# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Measurement, type: :model do
  context 'setting location' do
    let(:measurement) do
      Fabricate(:measurement, location: 'POINT(12.001 14.002)')
    end
    subject { measurement }

    its(:longitude) { should == 12.001 }
    its(:latitude) { should == 14.002 }
  end

  context 'setting lat and lng' do
    let(:measurement) do
      Fabricate(:measurement, longitude: 12.001,
                              latitude: 14.002)
    end
    subject { measurement }

    its(:longitude) { should == 12.001 }
    its(:latitude) { should == 14.002 }
  end

  context 'validation' do
    context 'md5sum' do
      describe 'uniqueness: true' do
        let(:params) { Fabricate.attributes_for(:measurement) }
        before do
          described_class.create!(params)
        end
        subject { described_class.create(params) }
        it { is_expected.to be_invalid }
      end
    end
  end

  describe '#approximate_count' do
    it 'shoulde return approximate count' do
      expect(described_class.approximate_count).to be_a(Numeric)
    end
  end
end
