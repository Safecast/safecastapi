# -*- encoding: utf-8 -*-

class PendingImportsReminder < Thor
  desc 'process', 'Send e-mails to who has pending imports'
  def process
    require_relative '../../config/environment'

    users = User.where(id: BgeigieImport.pending.group(:user_id).pluck(:user_id))
    users.each do |user|
      Reminders.pending_imports(user).deliver
    end
  end
end
