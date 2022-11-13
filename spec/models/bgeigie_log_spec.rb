# frozen_string_literal: true

RSpec.describe BgeigieLog do
  let(:bgeigie_log) { Fabricate(:bgeigie_log, cpm: 33) }

  describe '#location' do
    subject { bgeigie_log.location }

    it { is_expected.to eq(bgeigie_log.computed_location) }
  end

  describe '#location=' do
    before do
      bgeigie_log.location = 'POINT(139.7528 35.6852)'
    end

    it { expect(bgeigie_log.longitude).to eq(139.7528) }
    it { expect(bgeigie_log.latitude).to eq(35.6852) }
  end

  # XXX: rgeo-activerecord method
  describe '#longitude' do
    subject { bgeigie_log.longitude }

    it { is_expected.to eq(139.719176667) }
  end

  # XXX: rgeo-activerecord method
  describe '#latitude' do
    subject { bgeigie_log.latitude }

    it { is_expected.to eq(35.64214) }
  end

  describe '#usv' do
    subject(:usv) { bgeigie_log.usv }

    it 'should compute usv (micro Sievert per hour) from cpm' do
      expect(usv).to eq(0.1) # 33 / 330
    end
  end
end
