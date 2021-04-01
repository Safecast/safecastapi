# frozen_string_literal: true

require 'spec_helper'

require 'thor'
load Rails.root.join('lib', 'tasks', 'pending_imports_reminder.thor').to_s

RSpec.describe PendingImportsReminder do
  describe 'process' do
    before do
      alpha = Fabricate(:user)
      alpha.bgeigie_imports << Fabricate(:bgeigie_import, status: 'processed')
      alpha.bgeigie_imports << Fabricate(:bgeigie_import, status: 'done', approved: true)

      bravo = Fabricate(:user)
      bravo.bgeigie_imports << Fabricate(:bgeigie_import, status: 'done', approved: true)

      charlie = Fabricate(:user)
      charlie.bgeigie_imports << Fabricate(:bgeigie_import, status: 'processed')

      ActionMailer::Base.deliveries.clear

      described_class.new.invoke(:process)
    end

    it 'should send pending import reminders' do
      # should send to alpha and charlie
      expect(ActionMailer::Base.deliveries.count).to eq(2)
    end
  end
end
