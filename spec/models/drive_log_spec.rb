RSpec.describe DriveLog, type: :model do
  let(:drive_log) { described_class.create }

  describe '#update_md5sum' do
    before { drive_log.update_md5sum }

    subject { drive_log.md5sum }

    it { is_expected.to be_present }
  end

  describe '#update_location' do
    # FIXME: uninitialized constant DriveLog::Point
    it { expect { drive_log.update_location }.to raise_exception(NameError) }
  end
end
