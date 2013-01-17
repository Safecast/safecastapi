class ResetCounters < ActiveRecord::Migration
  def up
    User.find_each { |u| User.reset_counters(u, :measurements) }
    Device.find_each { |u| Device.reset_counters(u, :measurements) }
  end

  def down
  end
end
