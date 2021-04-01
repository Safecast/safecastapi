# frozen_string_literal: true

class RemoveDefaultWouldAutoApprove < ActiveRecord::Migration
  def change
    change_column_default :measurement_imports, :would_auto_approve, nil
  end
end
