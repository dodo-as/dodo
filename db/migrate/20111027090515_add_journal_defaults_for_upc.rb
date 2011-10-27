class AddJournalDefaultsForUpc < ActiveRecord::Migration
  def self.up
    add_column :journals, :default_unit, :integer
    add_column :journals, :default_project, :integer
    add_column :journals, :default_car, :integer
  end

  def self.down
    remove_column :journals, :default_unit
    remove_column :journals, :default_project
    remove_column :journals, :default_car
  end
end
