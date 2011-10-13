class JournalOperation < ActiveRecord::Base
  belongs_to :journal
  belongs_to :account
  belongs_to :ledger
  belongs_to :vat_account
  belongs_to :car
  belongs_to :project
  belongs_to :closed_operation
  belongs_to :company
  
  def debet= (num) 
    if num != "" and num.to_f > 0 then
      self.amount = -num.to_f
    end
  end
  
  def credit= (num)
    if num != "" and num.to_f > 0 then
      self.amount = num.to_f
    end
  end
  
  def debet
    return (self.amount<0.0) ? (-self.amount) : nil
  end

  def credit
    return (self.amount>0.0) ? self.amount : nil
  end
  
end
