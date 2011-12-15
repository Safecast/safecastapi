class CreateGroupsMeasurements < ActiveRecord::Migration
  def change
    create_table :groups_measurements, :id => false do |t|
      t.references :group, :measurement
    end
  end
end
