# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Reminders, type: :mailer do
  describe '.pending_imports' do
    let(:user) { Fabricate(:user) }

    it 'has subject' do
      mail = described_class.pending_imports(user)

      expect(mail.subject).to eq('Reminder: Your Safecast bGeigie logs')
    end
  end
end
