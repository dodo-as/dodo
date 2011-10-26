class RemoveExcessCarsFields < ActiveRecord::Migration
  def self.up
    remove_column :cars, :type
    remove_column :cars, :odometer
  end

  def self.down
    add_column :cars, :type, :string
    add_column :cars, :odometer, :integer
  end
end
