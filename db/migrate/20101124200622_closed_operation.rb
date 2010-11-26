class ClosedOperation < ActiveRecord::Migration
  def self.up
    create_table :closed_operations do |t|
    end
  end

  def self.down
    drop_table :closed_operations
  end
end
