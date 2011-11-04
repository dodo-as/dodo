class CreateAdminLogs < ActiveRecord::Migration
  def self.up
    create_table :admin_logs do |t|
      t.string :table_name, :null => false
      t.string :old_value, :null => false, :limit => 100000
      t.string :new_value, :null => false, :limit => 100000
      t.integer :admin_id, :null => false
      t.string :created_at

      t.timestamps
    end
  end

  def self.down
    drop_table :admin_logs
  end
end
