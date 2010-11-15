class IndexOperations < ActiveRecord::Migration
  def self.up
    add_column :journal_operations, :company_id, :int
    execute "update journal_operations jo set company_id = (select j.company_id from journals j where j.id = jo.journal_id)"
    execute "create index journal_operations_idx on journal_operations (company_id, account_id)"
    execute "cluster journal_operations_idx on journal_operations"
  end

  def self.down
    
  end
end
