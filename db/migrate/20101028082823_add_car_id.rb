class AddCarId < ActiveRecord::Migration
  def self.up
    add_column :journal_operations, :car_id, :integer
  end

  def self.down
    remove_column :journal_operations, :car_id
  end
end
