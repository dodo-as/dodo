class PaychecksAddCounty < ActiveRecord::Migration
  def self.up
     add_column :paychecks, :county_id, :integer
  end

  def self.down
     remove_column :paychecks, :county_id
  end
end
