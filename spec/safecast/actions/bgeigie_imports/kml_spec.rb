# frozen_string_literal: true

RSpec.describe Actions::BgeigieImports::Kml do
  describe '#call' do
    it 'should send file' do
      ctx = double('controller')
      expect(ctx).to receive(:send_data)
        .with(an_instance_of(String), hash_including(type: Mime::Type.lookup("kml").to_s))

      described_class.new([]).execute(ctx)
    end
  end
end
