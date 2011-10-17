class AddCarTypeToCars < ActiveRecord::Migration
  def self.up
    add_column :cars, :car_type, :string
  end

  def self.down
    remove_column :cars, :car_type
  end
end
