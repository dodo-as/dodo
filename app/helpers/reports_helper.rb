module ReportsHelper

  # options=> from_period, to_period
  def title_to_periods_range(options={})
    from_period = options[:from_period]
    to_period = options[:to_period]
    title = ""
    if from_period.blank? 
      title += "-- / "
    else
      title += from_period.year.to_s + "-" + from_period.nr.to_s + " / "
    end  
    if to_period.blank?
      title += "--"
    else
      title += to_period.year.to_s + "-" + to_period.nr.to_s + ""
    end  
    return title
  end
  
  def previous_balance(account, period)
    
    JournalOperation.sum(
      'amount', 
      :conditions =>[" account_id = ? AND ( periods.year < ? OR ( periods.year = ? AND periods.nr < ? ) ) ", account.id, period.year, period.year, period.nr], 
      :joins => "INNER JOIN journals ON journal_operations.journal_id = journals.id 
                 INNER JOIN periods ON journals.period_id = periods.id")
  end
  
end
