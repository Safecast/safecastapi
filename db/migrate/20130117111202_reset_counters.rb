class ResetCounters < ActiveRecord::Migration
  def up
    User.find_each { |u| User.reset_counters(u, :measurements) }
    Device.find_each { |d| Device.reset_counters(d, :measurements) }
  end

  def down
  end
end
