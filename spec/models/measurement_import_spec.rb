# frozen_string_literal: true

require 'spec_helper'

RSpec.describe MeasurementImport, type: :model do
  let(:source) { Rails.root.join('spec', 'fixtures', 'bgeigie0.log').open(File::RDONLY) }

  context 'validations' do
    describe 'uniqueness_of_md5sum' do
      let(:original_import) { described_class.create!(source: source) }

      before { original_import.save! }

      it 'should check uniqueness of md5sum' do
        import = described_class.create(source: source)
        expect(import).to be_invalid
        expect(import.errors).to be_key(:md5sum)

        # Showing that updating original import is okay.
        original_import.approved = true
        expect(original_import.save).to be_truthy
      end
    end
  end
end
