class CreateWeeklySaleShiftProductGroups < ActiveRecord::Migration
  def self.up
    create_table :weekly_sale_shift_product_groups do |t|
      t.references :weekly_sale_shift, :null=>false
      t.references :weekly_sale_setup_product_group, :null=>false
      t.float :amount, :null=>false, :default=>0.0
      t.float :quantity, :null=>false, :default=>0.0
      t.timestamps     
    end

    add_index :weekly_sale_shift_product_groups, [:weekly_sale_shift_id, :weekly_sale_setup_product_group_id], :name => :index_weekly_sale_shift_product_groups_shift_product_group, :unique => true

    execute "ALTER TABLE weekly_sale_shift_product_groups ADD CONSTRAINT fk_weekly_sale_shift_product_groups_weekly_sale_shift FOREIGN KEY (weekly_sale_shift_id)  REFERENCES weekly_sale_shifts(id) ON DELETE CASCADE "
    execute "ALTER TABLE weekly_sale_shift_product_groups ADD CONSTRAINT fk_weekly_sale_shift_product_groups_weekly_sale_setup_product_group FOREIGN KEY (weekly_sale_setup_product_group_id)  REFERENCES weekly_sale_setup_product_groups(id) "

  end

  def self.down
    drop_table :weekly_sale_shift_product_groups
  end
end
