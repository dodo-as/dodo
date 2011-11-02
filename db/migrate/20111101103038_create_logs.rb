class CreateLogs < ActiveRecord::Migration
  def self.up
    create_table :logs do |t|
      t.string :table_name, :null => false
      t.string :old_value, :null => false, :limit => 100000
      t.string :new_value, :null => false, :limit => 100000
      t.references :user, :null => false
      t.references :company, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :logs
  end
end
