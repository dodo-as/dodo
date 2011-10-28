class AddVatChunks < ActiveRecord::Migration
  def self.up
    create_table :vat_chunks do |t|
      t.integer :number, :null => false
      t.date :start_date, :null => false
      t.date :stop_date
      t.references :company, :null => false
      t.references :account, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :vat_chunks
  end
end
