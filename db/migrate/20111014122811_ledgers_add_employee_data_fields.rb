class LedgersAddEmployeeDataFields < ActiveRecord::Migration
  def self.up
    add_column :ledgers, :salary_email, :string
    add_column :ledgers, :personal_number, :string
    add_column :ledgers, :date_of_birth, :date
    add_column :ledgers, :tabelltrekk, :integer
    add_column :ledgers, :procenttrekk, :integer
  end

  def self.down
    remove_column :ledgers, :salary_email
    remove_column :ledgers, :personal_number
    remove_column :ledgers, :date_of_birth
    remove_column :ledgers, :tabelltrekk
    remove_column :ledgers, :procenttrekk
  end
end
