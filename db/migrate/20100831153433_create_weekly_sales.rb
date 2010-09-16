class CreateWeeklySales < ActiveRecord::Migration
  def self.up
    create_table :weekly_sales do |t|
      t.references :weekly_sale_setup, :null=>false
      t.references :period, :null=>false
      t.references :company, :null=>false
      t.references :journal
      t.date :journal_date, :null=>false
      t.integer :journal_number
      t.integer :week, :null=>false
      t.date :from_date, :null=>false
      t.date :to_date, :null=>false
      t.float :total_product_group_amount, :null=>false, :default=>0.0
      t.float :total_actual_cash_amount, :null=>false, :default=>0.0
      t.float :total_liquid_amount, :null=>false, :default=>0.0
      t.float :total_inserted_cash_amount, :null=>false, :default=>0.0
      t.float :total_extracted_cash_amount, :null=>false, :default=>0.0
      t.float :private_amount, :null=>false, :default=>0.0
      t.string :private_amount_explanation, :limit=>100
      t.float :total_net, :null=>false, :default=>0
      t.boolean :closed, :null=>false, :default=>false
      t.integer :closed_by
      t.datetime :closed_at
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end

    add_index :weekly_sales, [:weekly_sale_setup_id, :period_id, :from_date, :to_date, :week], :unique => true, :name=>'weekly_sales_on_weekly_sale_setup_id_and_period_id_and_week' 

    execute "ALTER TABLE weekly_sales ADD CONSTRAINT fk_weekly_sales_period FOREIGN KEY (period_id)  REFERENCES periods(id) "
    execute "ALTER TABLE weekly_sales ADD CONSTRAINT fk_weekly_sales_journal FOREIGN KEY (journal_id)  REFERENCES journals(id) "
    execute "ALTER TABLE weekly_sales ADD CONSTRAINT fk_weekly_sales_wueekly_sale_setup FOREIGN KEY (weekly_sale_setup_id)  REFERENCES weekly_sale_setups(id) "
    execute "ALTER TABLE weekly_sales ADD CONSTRAINT fk_weekly_sales_closed_by FOREIGN KEY (closed_by)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sales ADD CONSTRAINT fk_weekly_sales_created_by FOREIGN KEY (created_by)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sales ADD CONSTRAINT fk_weekly_sales_updated_by FOREIGN KEY (updated_by)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sales ADD CONSTRAINT fk_weekly_sales_company FOREIGN KEY (company_id)  REFERENCES companies(id) "

  end

  def self.down
    drop_table :weekly_sales
  end
end
