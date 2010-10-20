class RenameLodoName < ActiveRecord::Migration
  def self.up
    rename_column(:accounts, :lodo_name, :dodo_name)
  end

  def self.down
    rename_column(:accounts, :dodo_name, :lodo_name)
  end
end
