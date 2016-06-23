module BgeigieImportState
  def metadata_added?
    credits.present? && cities.present?
  end

  def queued_for_processing?
    status_details.empty?
  end

  def done?
    status == 'done'
  end

  def submitted?
    status == 'submitted' || approved?
  end

  def processed?
    status == 'processed' || submitted? || done?
  end

  def ready_for_submission?
    metadata_added? && processed?
  end

  def awaiting_approval?
    submitted? && !approved?
  end
end
