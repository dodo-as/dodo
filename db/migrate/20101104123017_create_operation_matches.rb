class CreateOperationMatches < ActiveRecord::Migration
  def self.up
    create_table :operation_matches do |t|

      t.timestamps
    end
  end

  def self.down
    drop_table :operation_matches
  end
end
