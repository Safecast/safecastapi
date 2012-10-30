class ImportAwaitingApprovalDigestMailer < ActiveRecord::Base
  has_many :bgeigie_imports, :foreign_key => :digest_id

  attr_accessible :status, :initialized_at, :send_at

  def self.addImport(import)
    current = currentDigest
    unless current
      current = create({
        :initialized_at => DateTime.now,
        :send_at => 1.day.from_now,
        :status => 'unsent'
      })
      handle_asynchronously :send_digest, :run_at => Proc.new { currentDigest.send_at }
      binding.pry
    end

    current.bgeigie_imports << import
  end

  def self.queuedImports
    if currentDigest
      currentDigest.bgeigie_imports
    else
      []
    end
  end

  def self.currentDigest
    where("status = 'unsent'").first
  end

  def send_digest
    # this has to be an instance method for delayed_job to like it.
    # frustrating.
    current = self.currentDigest
    imports = current.bgeigie_imports
    Notifications.import_awaiting_approval_digest(imports).deliver
    current.status = 'sent'
    current.save
  end
end
