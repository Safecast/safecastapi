require 'spec_helper'

RSpec.describe Notifications, type: :mailer do
  describe '.send_email' do
    let(:import) do
      double('import').tap do |d|
        expect(d).to receive(:user).and_return(double('user', email: 'user@example.org'))
        expect(d).to receive(:filename).and_return('filename.txt')
      end
    end

    subject { described_class.send_email(import, 'e-mail body', 'sender@example.org') }

    it { is_expected.to be_present }
  end

  describe '.contact_moderator' do
    let(:import) do
      double('import').tap do |d|
        expect(d).to receive(:rejected_by).and_return('admin@example.org')
        expect(d).to receive(:filename).and_return('filename.txt')
      end
    end

    subject { described_class.contact_moderator(import, 'e-mail body', 'sender@example.org') }

    it { is_expected.to be_present }
  end
end
