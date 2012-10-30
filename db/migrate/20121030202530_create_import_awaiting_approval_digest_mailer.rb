class CreateImportAwaitingApprovalDigestMailer < ActiveRecord::Migration
  def change
    create_table :import_awaiting_approval_digest_mailers do |t|
      t.datetime :initialized_at
      t.datetime :send_at
      t.string   :status, :default => 'unsent'
    end

    # measurement_import belongs_to import_awaiting_approval_digest
    # import_awaiting_approval_digest has_many measurement_imports
    add_column :measurement_imports, :digest_id, :integer
    add_index :measurement_imports, :digest_id
  end
end
