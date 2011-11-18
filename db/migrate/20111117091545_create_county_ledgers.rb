class CreateCountyLedgers < ActiveRecord::Migration
  def self.up
    create_table :county_ledgers do |t|
      t.integer :county_id
      t.integer :ledger_id
      t.date :from
      t.timestamps
    end
  end

  def self.down
    drop_table :county_ledgers
  end
end

