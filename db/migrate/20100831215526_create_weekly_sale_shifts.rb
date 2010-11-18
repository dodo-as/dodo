class CreateWeeklySaleShifts < ActiveRecord::Migration
  def self.up
    create_table :weekly_sale_shifts do |t|
      t.references :weekly_sale, :null=>false
      t.date :date
      t.boolean :closed, :default=>false
      t.integer :closed_by_id
      t.datetime :closed_at
      t.integer :sign_by_id
      t.datetime :sign_at
      t.integer :z_number
      t.float :z_amount, :null=>false, :default=>0.0
      t.float :total_product_group_amount, :default=>0.0
      t.float :total_liquid_amount, :default=>0.0
      t.float :actual_cash_amount, :default=>0.0
      t.float :received_cash_amount, :default=>0.0
      t.float :difference_cash, :default=>0.0
      t.string :difference_cash_explanation, :limit=>100
      t.float :inserted_cash_amount, :default=>0.0
      t.float :extracted_cash_amount, :default=>0.0

      t.integer :created_by_id
      t.integer :updated_by_id
      t.timestamps
    end

    execute "ALTER TABLE weekly_sale_shifts ADD CONSTRAINT fk_weekly_sale_shifts_weekly_sale FOREIGN KEY (weekly_sale_id)  REFERENCES weekly_sales(id) "
    execute "ALTER TABLE weekly_sale_shifts ADD CONSTRAINT fk_weekly_sale_shifts_closed_by FOREIGN KEY (closed_by_id)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sale_shifts ADD CONSTRAINT fk_weekly_sale_shifts_created_by FOREIGN KEY (created_by_id)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sale_shifts ADD CONSTRAINT fk_weekly_sale_shifts_updated_by FOREIGN KEY (updated_by_id)  REFERENCES users(id) "


  end

  def self.down
    drop_table :weekly_sale_shifts
  end
end
