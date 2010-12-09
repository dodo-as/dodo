class CreateWeeklySaleShiftLiquids < ActiveRecord::Migration
  def self.up
    create_table :weekly_sale_shift_liquids do |t|
      t.references :weekly_sale_shift, :null=>false
      t.references :weekly_sale_setup_liquid, :null=>false
      t.float :amount, :null=>false, :default=>0.0     
      t.timestamps
    end
    add_index :weekly_sale_shift_liquids, [:weekly_sale_shift_id, :weekly_sale_setup_liquid_id], :name => "index_weekly_sale_shift_liquids_shift_setup_liquid", :unique => true

    execute "ALTER TABLE weekly_sale_shift_liquids ADD CONSTRAINT fk_weekly_sale_shift_liquids_weekly_sale_shift FOREIGN KEY (weekly_sale_shift_id)  REFERENCES weekly_sale_shifts(id) ON DELETE CASCADE"
    execute "ALTER TABLE weekly_sale_shift_liquids ADD CONSTRAINT fk_weekly_sale_shift_liquids_weekly_sale_setup_liquid FOREIGN KEY (weekly_sale_setup_liquid_id)  REFERENCES weekly_sale_setup_liquids(id) "

  end

  def self.down
    drop_table :weekly_sale_shift_liquids
  end
end
