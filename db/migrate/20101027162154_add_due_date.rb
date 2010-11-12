class AddDueDate < ActiveRecord::Migration
  def self.up
    add_column :journals, :due_date, :datetime
  end

  def self.down
    remove_column :journals, :due_date
  end
end
