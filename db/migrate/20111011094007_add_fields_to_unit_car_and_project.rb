
class AddFieldsToUnitCarAndProject < ActiveRecord::Migration
  def self.up
    
    add_column :units, :from, :date
    add_column :units, :to, :date
    
    add_column :cars, :from, :date
    add_column :cars, :to, :date
    add_column :cars, :type, :string
    add_column :cars, :odometer, :integer
    
    add_column :projects, :from, :date
    add_column :projects, :to, :date
    
  end
  
  def self.down
    
    remove_column :units, :from
    remove_column :units, :to
    
    remove_column :cars, :from
    remove_column :cars, :to
    remove_column :cars, :type
    remove_column :cars, :odometer
    
    remove_column :projects, :from
    remove_column :projects, :to
    
  end
end


