# frozen_string_literal: true

RSpec.describe BgeigieImport do
  let(:user) { Fabricate(:user) }

  describe '#initialize' do
    it 'should set subtype to "None" by default' do
      expect(described_class.new.subtype).to eq('None')
    end

    it 'should use provided subtype' do
      expect(described_class.new(subtype: 'Drive').subtype)
        .to eq('Drive')
    end
  end

  describe '#process' do
    let(:bgeigie_import) do
      create_bgeigie_import(log_name, user)
    end

    before do
      bgeigie_import.process
      bgeigie_import.finalize!
    end

    context 'valid log file' do
      let(:log_name) { 'bgeigie' }

      it 'should create 23 Bgeigie Logs' do
        expect(BgeigieLog.count).to eq(23)
      end

      it 'should count the number of lines in the file' do
        expect(bgeigie_import.lines_count).to eq(23)
      end

      it 'should set the id' do
        expect(BgeigieLog.all.collect(&:bgeigie_import_id).uniq).to eq([bgeigie_import.id])
      end

      it 'should create measurements' do
        expect(Measurement.count).to eq(23)
      end

      it 'should not load them twice' do
        bgeigie_import.process
        expect(Measurement.count).to eq(23)
      end

      it 'should set measurement attributes' do
        measurement = Measurement.find_by_md5sum('6750a7cf2a630c2dde416dc7d138fa74')
        expect(measurement.location).to be_present
        expect(measurement.captured_at).to be_present
      end
    end

    context 'valid log file that is measured in N.Y.C.' do
      let(:log_name) { 'bgeigie_nyc' }

      it 'should calculate measurements to the correct hemisphere' do
        measurement = Measurement.find_by_md5sum('c435ff4da6a7a16e92282bd10381b6d7')

        expect(measurement.location.x).to eq(-73.92277166666666)
        expect(measurement.location.y).to eq(41.698078333333335)
      end
    end

    context 'invalid log file that contains GPS bug' do
      let(:log_name) { 'bgeigie_with_tinygps_bug' }

      it 'should calculate measurements to the correct hemisphere' do
        measurement = Measurement.find_by_md5sum('97badba59dda4a56958fc40b16277db4')

        expect(measurement.location.x).to eq(-73.92259666666666)
        expect(measurement.location.y).to eq(41.69836166666666)
      end
    end

    context 'invalid log file with data corruptions' do
      let(:log_name) { 'bgeigie_with_corruption' }

      it 'should import upto corrupted line' do
        expect(Measurement.count).to eq(7)
      end
    end

    context 'corrupted log file that cannot be imported' do
      let(:log_name) { 'malformed_bgeigie' }

      it 'should reject' do
        expect(bgeigie_import).to be_rejected
        expect(bgeigie_import.rejected_by).to be_present
      end

      it 'should not import any measurements' do
        expect(Measurement.count).to be_zero
      end
    end
  end

  def create_bgeigie_import(log_name, user)
    Fabricate(:bgeigie_import, source: fixture_log(log_name), user: user)
  end

  def fixture_log(name)
    Rails.root.join("spec/fixtures/#{name}.log").open
  end
end
