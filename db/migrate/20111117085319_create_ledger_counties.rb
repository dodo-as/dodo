class CreateLedgerCounties < ActiveRecord::Migration
  def self.up
    create_table :ledger_counties do |t|
       t.integer :ledger_id
       t.integer :county_id
       t.date :from
      t.timestamps
    end
  end

  def self.down
    drop_table :ledger_counties
  end
end
