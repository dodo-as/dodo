class CreateWeeklySaleSetupProductGroups < ActiveRecord::Migration
  def self.up
    create_table :weekly_sale_setup_product_groups do |t|
      t.string :name, :limit=>100, :null=>false
      t.references :project, :null=>false
      t.references :account, :null=>false
      t.references :weekly_sale_setup, :null=>false
      t.references :company, :null=>false
      t.integer :display_order, :null=>false, :default=>0
      t.integer :created_by
      t.integer :updated_by

      t.timestamps
    end
    add_index :weekly_sale_setup_product_groups, [:name, :weekly_sale_setup_id], :unique => true 
    execute "ALTER TABLE weekly_sale_setup_product_groups ADD CONSTRAINT fk_weekly_sale_setup_product_groups_project FOREIGN KEY (project_id)  REFERENCES projects(id) "
    execute "ALTER TABLE weekly_sale_setup_product_groups ADD CONSTRAINT fk_weekly_sale_setup_product_groups_account FOREIGN KEY (account_id)  REFERENCES accounts(id) "
    execute "ALTER TABLE weekly_sale_setup_product_groups ADD CONSTRAINT fk_weekly_sale_setup_product_groups_wueekly_sale_setup FOREIGN KEY (weekly_sale_setup_id)  REFERENCES weekly_sale_setups(id) "
    execute "ALTER TABLE weekly_sale_setup_product_groups ADD CONSTRAINT fk_weekly_sale_setup_product_groups_created_by FOREIGN KEY (created_by)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sale_setup_product_groups ADD CONSTRAINT fk_weekly_sale_setup_product_groups_updated_by FOREIGN KEY (updated_by)  REFERENCES users(id) "
    execute "ALTER TABLE weekly_sale_setup_product_groups ADD CONSTRAINT fk_weekly_sale_setup_product_groups_company FOREIGN KEY (company_id)  REFERENCES companies(id) "
  end

  def self.down
    drop_table :weekly_sale_setup_product_groups
  end
end
