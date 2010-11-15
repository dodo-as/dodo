class Journal < ActiveRecord::Base
  has_many :journal_operations, :autosave => true
  belongs_to :company
  belongs_to :bill
  belongs_to :period
  belongs_to :unit
  belongs_to :journal_type 

  self.per_page = 200

  def open?
   return (not self.closed)
  end

  def editable?
    return (self.period.open? and self.open? and self.bill_id.nil?)
  end

  def self.get_ledger_by_account(from_period, to_period, company, department, project, show_last_period)

    
  end

end
