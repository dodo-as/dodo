module ReportsHelper
  
  def previous_balance(account, period)
    
    JournalOperation.sum(
      'amount', 
      :conditions =>[" account_id = ? AND ( periods.year < ? OR ( periods.year = ? AND periods.nr < ? ) ) ", account.id, period.year, period.year, period.nr], 
      :joins => "INNER JOIN journals ON journal_operations.journal_id = journals.id 
                 INNER JOIN periods ON journals.period_id = periods.id")
  end
  
end
