class AddVisibilityFlagCounties < ActiveRecord::Migration
  def self.up
      add_column :counties, :is_visible, :boolean, :default=>true
  end

  def self.down
      remove_column :counties, :is_visible
  end
end
