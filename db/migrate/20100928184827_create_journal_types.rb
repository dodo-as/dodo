class CreateJournalTypes < ActiveRecord::Migration
  def self.up
    create_table :journal_types do |t|
      t.string :name, :limit=>100, :null=>false

      t.timestamps
    end

    JournalType.create!(:name=>'Weekly Sale')
  end

  def self.down
    drop_table :journal_types
  end
end
