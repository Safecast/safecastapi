require 'spec_helper'

RSpec.describe Notifications, type: :mailer do
  describe '.import_awaiting_approval' do
    context 'no moderator' do
      it 'should not raise error' do
        expect { described_class.import_awaiting_approval(nil) }
          .to_not raise_error
      end
    end
  end
end
