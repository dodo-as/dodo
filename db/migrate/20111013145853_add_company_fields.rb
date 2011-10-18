class AddCompanyFields < ActiveRecord::Migration
  def self.up
    
    remove_column :companies, :address_id

    add_column :companies, :visiting_address_id, :integer
    add_column :companies, :billing_address_id, :integer
    add_column :companies, :delivery_address_id, :integer
    add_column :companies, :county_id, :integer
    add_column :companies, :show_turnover, :boolean  
    add_column :companies, :bill_comment_top, :boolean
    add_column :companies, :bill_line_comment_top, :boolean
    add_column :companies, :telephone_number, :string
    add_column :companies, :fax, :string
    add_column :companies, :mobile_number, :string
    add_column :companies, :email, :string
    add_column :companies, :web_site, :string
    add_column :companies, :bank_account, :string

    add_column :companies, :interest_rate, :decimal, :precision=> 5, :scale => 2
    add_column :companies, :late_fee, :decimal, :precision=> 10, :scale => 2
    
    add_column :companies, :share_value, :decimal, :precision=> 20, :scale => 2
    add_column :companies, :share_count, :integer
    add_column :companies, :incorporation_date, :date
    
    add_column :companies, :result_account_balance_id, :integer
    add_column :companies, :result_account_result_id, :integer
    
    add_column :companies, :information, :string
    add_column :companies, :deliver_terms, :string
    add_column :companies, :payment_terms, :string
    add_column :companies, :sector, :string
  end

  def self.down
    
    add_column :companies, :address_id, :integer
    
    remove_column :companies, :visiting_address_id
    remove_column :companies, :billing_address_id
    remove_column :companies, :delivery_address_id
    remove_column :companies, :county_id
    remove_column :companies, :show_turnover
    remove_column :companies, :bill_comment_top
    remove_column :companies, :bill_line_comment_top
    remove_column :companies, :telephone_number
    remove_column :companies, :fax
    remove_column :companies, :mobile_number
    remove_column :companies, :email
    remove_column :companies, :web_site
    remove_column :companies, :bank_account
    remove_column :companies, :interest_rate, :decimal, :precision=> 5
    remove_column :companies, :late_fee, :decimal, :precision=> 10
    remove_column :companies, :share_value, :decimal, :precision=> 20
    remove_column :companies, :share_count
    remove_column :companies, :incorporation_date
    remove_column :companies, :result_account_balance_id
    remove_column :companies, :result_account_result_id
    remove_column :companies, :information
    remove_column :companies, :deliver_terms
    remove_column :companies, :payment_terms
    remove_column :companies, :sector

  end
end
