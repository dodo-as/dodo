class CreateTravelLogs < ActiveRecord::Migration
  def self.up
    create_table :travel_logs do |t|
      t.integer :odometer, :null => false
      t.date :date, :null => false

      t.timestamps
      t.integer :car_id, :null => false
    end
    add_index :travel_logs, :car_id
  end

  def self.down
    drop_table :travel_logs
  end
end
