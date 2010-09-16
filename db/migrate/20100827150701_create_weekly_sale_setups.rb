class CreateWeeklySaleSetups < ActiveRecord::Migration
  def self.up
    create_table :weekly_sale_setups do |t|      
      t.string :name, :limit=>100, :null=>false
      t.string :voucher_type, :limit=>3, :null=>false
      t.float :permanent_cash, :default=>0.0, :null=>false
      t.boolean :locked, :null=>false      
      t.date :valid_from, :null=>false
      t.date :valid_to  
      t.references :cash_account, :null=>false 
      t.references :unit, :null=>false
      t.references :company, :null=>false         
      t.integer :created_by
      t.integer :updated_by
      t.timestamps
    end
    add_index :weekly_sale_setups, [:name, :company_id], :unique => true 
    execute "ALTER TABLE weekly_sale_setups ADD CONSTRAINT fk_weekly_sale_setups_cash_account FOREIGN KEY (cash_account_id)  REFERENCES accounts(id) "
    execute "ALTER TABLE weekly_sale_setups ADD CONSTRAINT fk_weekly_sale_setups_unit FOREIGN KEY (unit_id)  REFERENCES units(id) "
    execute "ALTER TABLE weekly_sale_setups ADD CONSTRAINT fk_weekly_sale_setups_created_by FOREIGN KEY (created_by)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sale_setups ADD CONSTRAINT fk_weekly_sale_setups_updated_by FOREIGN KEY (updated_by)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sale_setups ADD CONSTRAINT fk_weekly_sale_setups_company FOREIGN KEY (company_id)  REFERENCES companies(id) "
  end

  def self.down
    drop_table :weekly_sale_setups
  end
end
