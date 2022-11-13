# frozen_string_literal: true

RSpec.describe DriveImport do
  let!(:user) { User.where(id: 1).first || Fabricate(:user, id: 1) }

  let(:drive_import_source) do
    f = Tempfile.new('drive_import_source')
    f.write('123')
    f.rewind
    Rack::Test::UploadedFile.new(f.path, 'text/plain')
  end

  let(:drive_import_params_base) do
    { source: drive_import_source, description: 'Test' }
  end

  let(:drive_import) { described_class.create(drive_import_params) }

  describe '#name' do
    subject { drive_import.name }

    context 'when it has name' do
      let(:drive_import_params) { drive_import_params_base.merge(name: 'MyDrive') }

      it { is_expected.to eq('MyDrive') }
    end

    context 'when it has no name' do
      let(:drive_import_params) { drive_import_params_base }

      it { is_expected.to eq("Drive ##{drive_import.id}") }
    end
  end

  describe '#process' do
    let(:drive_import_params) { drive_import_params_base }

    before { drive_import.process }

    it { expect(drive_import.map).to be_present }
    it { expect(drive_import.status).to eq('done') }
  end

  describe '#user' do
    let(:drive_import_params) { drive_import_params_base }

    subject { drive_import.user }

    it { is_expected.to eq(user) }
  end

  describe '#user_id' do
    let(:drive_import_params) { drive_import_params_base }

    subject { drive_import.user_id }

    it { is_expected.to eq(1) }
  end
end
