class Journal < ActiveRecord::Base
  has_many :journal_operations, :autosave => true
  belongs_to :company
  belongs_to :bill
  belongs_to :period
  belongs_to :unit
  belongs_to :journal_type 

  self.per_page = 200

  def to_s
    "Journal #{self.id}: #{self.company} #{self.journal_type} #{self.number}"
  end

  def open?
    return (not self.closed)
  end

  def editable?
    return (self.period.open? and self.open? and self.bill_id.nil?)
  end

  def self.report_ledger_balance(periods_to_balance, periods_to_balance_previous, 
      periods_to_balance_last, periods_to_balance_last_previous,
      periods_to_result, periods_to_result_last,
      company, unit, project,car, show_only_active_accounts)

    #preparing periods to string fromat for sql query.
    unless periods_to_balance.blank?
      _periods_to_balance = periods_to_balance.collect { |p| p.id }.join(",") 
    end
    unless periods_to_balance_previous.blank?
      _periods_to_balance_previous = periods_to_balance_previous.collect { |p| p.id }.join(",") 
    end

    unless periods_to_balance_last.blank?
      _periods_to_balance_last = periods_to_balance_last.collect { |p| p.id }.join(",")
    end
    unless periods_to_balance_last_previous.blank?
      _periods_to_balance_last_previous = periods_to_balance_last_previous.collect { |p| p.id }.join(",")
    end

    unless periods_to_result.blank?
      _periods_to_result = periods_to_result.collect { |p| p.id }.join(",")
    end
    unless periods_to_result_last.blank?
      _periods_to_result_last = periods_to_result_last.collect { |p| p.id }.join(",")
    end

    ###############################
    ##### calculating balance #####
    ###############################
    sql = "select id as account_id,  
          max(account_number) as account_number, 
          max(account_name) as account_name, 
          sum(total_period) as total_period,
          sum(total_period_previous) as total_period_previous,
          sum(total_last_period) as total_last_period,
          sum(total_last_period_previous) as total_last_period_previous,
          0 as balance_period,
          0 as balance_last_period
          from  ("
    unless _periods_to_balance.blank?
      sql += " -- account balance
            select accounts.id, max(accounts.number) as account_number, 
            max(accounts.name) as account_name, 
            sum(journal_operations.amount) as total_period, 
            0 as total_period_previous,
            0 as total_last_period,
            0 as total_last_period_previous
            from periods inner join journals on periods.id = journals.period_id 
            inner join journal_operations on journals.id = journal_operations.journal_id
            inner join accounts on journal_operations.account_id = accounts.id 
            where journals.company_id = #{company.id}
            and periods.id in (#{_periods_to_balance}) 
            and accounts.is_result_account = false"
      unless unit.blank?
        sql += " and journal_operations.unit_id = #{unit.id}"
      end
      unless project.blank?
        sql += " and journal_operations.project_id = #{project.id}"
      end
      unless car.blank?
        sql += " and journal_operations.car_id = #{car.id}"
      end
      sql +=" group by accounts.id "
    end
    unless _periods_to_balance_last.blank?           
      sql += " -- last period, account balance
            union 
            select accounts.id, max(accounts.number) as account_number, 
            max(accounts.name) as account_name, 
            0 as total_period, 
            0 as total_period_previous,
            sum(journal_operations.amount) as total_last_period,
            0 as total_last_period_previous
            from periods inner join journals on periods.id = journals.period_id 
            inner join journal_operations on journals.id = journal_operations.journal_id
            inner join accounts on journal_operations.account_id = accounts.id
            where journals.company_id = #{company.id}
            and periods.id in (#{_periods_to_balance_last}) 
            and accounts.is_result_account = false"
      unless unit.blank?
        sql += " and journal_operations.unit_id = #{unit.id}"
      end  
      unless project.blank?
        sql += " and journal_operations.project_id = #{project.id}"
      end
      unless car.blank?
        sql += " and journal_operations.car_id = #{car.id}"
      end
      sql +=" group by accounts.id "
    end   
    unless _periods_to_balance_previous.blank?  
      sql += " -- period previous, account balance
          union 
          select accounts.id, max(accounts.number) as account_number, 
          max(accounts.name) as account_name, 
          0 as total_period, 
          sum(journal_operations.amount) as total_period_previous,
          0 as total_last_period,
          0 as total_last_period_previous             
          from periods inner join journals on periods.id = journals.period_id 
          inner join journal_operations on journals.id = journal_operations.journal_id
          inner join accounts on journal_operations.account_id = accounts.id
          where journals.company_id = #{company.id}
          and periods.id in (#{_periods_to_balance_previous})
          and accounts.is_result_account = false"
      unless unit.blank?
        sql += " and journal_operations.unit_id = #{unit.id}"
      end  
      unless project.blank?
        sql += " and journal_operations.project_id = #{project.id}"
      end
      unless car.blank?
        sql += " and journal_operations.car_id = #{car.id}"
      end
      sql +=" group by accounts.id "
    end
    unless _periods_to_balance_last_previous.blank?
      sql += " -- last period previous, account balance
          union 
          select accounts.id, max(accounts.number) as account_number, 
          max(accounts.name) as account_name, 
          0 as total_period, 
          0 as total_period_previous,
          0 as total_last_period,
          sum(journal_operations.amount) as total_last_period_previous
          from periods inner join journals on periods.id = journals.period_id 
          inner join journal_operations on journals.id = journal_operations.journal_id
          inner join accounts on journal_operations.account_id = accounts.id
          where journals.company_id = #{company.id}
          and periods.id in (#{_periods_to_balance_last_previous})
          and accounts.is_result_account = false"
      unless unit.blank?
        sql += " and journal_operations.unit_id = #{unit.id}"
      end  
      unless project.blank?
        sql += " and journal_operations.project_id = #{project.id}"
      end
      unless car.blank?
        sql+= " and journal_operations.car_id = #{car.id}"
      end
      sql +=" group by accounts.id "
    end
    if show_only_active_accounts.blank?
      sql += " --- union with all balance accounts
          union
          select id, number as account_number, 
          name as account_name, 
          0 as total_period, 
          0 as total_period_previous,
          0 as total_last_period,
          0 as total_last_period_previous
          from accounts
          where company_id = #{company.id}
          and is_result_account = false"
    end
    sql += "
        ) as result 
        group by account_id
        order by account_number"


    balance = Journal.find_by_sql(sql)   

    total_period_previous = 0
    total_period = 0
    total_balance_period = 0
    total_last_period_previous = 0
    total_last_period = 0
    total_balance_last_period = 0
    total_accounts_1000 = 0
    total_accounts_2000 = 0

    balance.each do |row|      
      row["balance_period"] = row.total_period.to_f + row.total_period_previous.to_f
      row["balance_last_period"] = row.total_last_period.to_f + row.total_last_period_previous.to_f
      total_period_previous += row["total_period_previous"].to_f
      total_period += row["total_period"].to_f
      total_balance_period += row["balance_period"]
      total_last_period_previous += row["total_last_period_previous"].to_f
      total_last_period += row["total_last_period"].to_f
      total_balance_last_period += row["balance_last_period"]
      case row["account_number"].to_i
      when 1000..1999 then total_accounts_1000 += row["balance_period"]
      when 2000..2999 then total_accounts_2000 += row["balance_period"]
      end
    end
    total_balance =  Hash.new 
    total_balance["total_period_previous"]=total_period_previous
    total_balance["total_period"]=total_period
    total_balance["total_balance_period"] = total_balance_period
    total_balance["total_last_period_previous"] = total_last_period_previous
    total_balance["total_last_period"] = total_last_period
    total_balance["total_balance_last_period"] = total_balance_last_period
    total_balance["total_accounts_1000"] = total_accounts_1000
    total_balance["total_accounts_2000"] = total_accounts_2000


    ###############################
    ##### calculating result ######
    ###############################
    sql = "
        -- accounts results
        select id as account_id,  
        max(account_number) as account_number, 
        max(account_name) as account_name, 
        sum(total_period) as total_period,
        sum(total_last_period) as total_last_period
        from  ("
    unless _periods_to_result.blank? 
      sql += " select accounts.id, max(accounts.number) as account_number, 
          max(accounts.name) as account_name, 
          sum(journal_operations.amount) as total_period, 
          0 as total_last_period
          from periods inner join journals on periods.id = journals.period_id 
          inner join journal_operations on journals.id = journal_operations.journal_id
          inner join accounts on journal_operations.account_id = accounts.id
          where journals.company_id = #{company.id}
          and periods.id in (#{_periods_to_result})       
          and accounts.is_result_account = true"
      unless unit.blank?
        sql += " and journal_operations.unit_id = #{unit.id}"
      end  
      unless project.blank?
        sql += " and journal_operations.project_id = #{project.id}"
      end
      unless car.blank?
        sql += " and journal_operations.car_id = #{car.id}"
      end
      sql +=" group by accounts.id "
    end
    unless _periods_to_result_last.blank?
      sql += "-- last period, accounts result
          union 
          select accounts.id, max(accounts.number) as account_number, 
          max(accounts.name) as account_name, 
          0 as total_period, 
          sum(journal_operations.amount) as total_last_period
          from periods inner join journals on periods.id = journals.period_id 
          inner join journal_operations on journals.id = journal_operations.journal_id
          inner join accounts on journal_operations.account_id = accounts.id
          where journals.company_id = #{company.id} 
          and periods.id in (#{_periods_to_result_last})
          and accounts.is_result_account = true"
      unless unit.blank?
        sql += " and journal_operations.unit_id = #{unit.id}"
      end  
      unless project.blank?
        sql += " and journal_operations.project_id = #{project.id}"
      end
      unless car.blank?
        sql += " and journal_operations.car_id = #{car.id}"
      end
      sql +=" group by accounts.id "
    end
    if show_only_active_accounts.blank?
      sql +="
          --- union with all result accounts
          union
          select id, number as account_number, 
          name as account_name, 
          0 as total_period, 
          0 as total_last_period
          from accounts
          where company_id = #{company.id}
          and accounts.is_result_account = true"
    end
    sql +="
        ) as result
        group by account_id
        order by account_number "
 
    result = Journal.find_by_sql(sql)   
    
    total_period = 0
    total_last_period = 0
    total_accounts_3000 = 0
    total_accounts_4000 = 0
    total_accounts_5000 = 0
    total_accounts_6000 = 0
    total_accounts_7000 = 0
    total_accounts_8000 = 0
    total_accounts_9000 = 0

    result.each do |row|      
      total_period += row["total_period"].to_f
      total_last_period += row["total_last_period"].to_f
      #      puts "account number = "+row["account_number"]
      #      puts "account number first digit = "+row["account_number"][0,1]
      #      puts "amount  = "+row["total_last_period"]
      case row["account_number"].to_i
      when 3000..3999 then total_accounts_3000 += row["total_period"].to_f
      when 4000..4999 then total_accounts_4000 += row["total_period"].to_f
      when 5000..5999 then total_accounts_4000 += row["total_period"].to_f
      when 6000..6999 then total_accounts_4000 += row["total_period"].to_f
      when 7000..7999 then total_accounts_4000 += row["total_period"].to_f
      when 8000..8999 then total_accounts_4000 += row["total_period"].to_f
      when 9000..9999 then total_accounts_4000 += row["total_period"].to_f
      end
    end
    total_result =  Hash.new 
    total_result["total_period"]=total_period
    total_result["total_last_period"] = total_last_period
    total_result["total_accounts_3000"] = total_accounts_3000
    total_result["total_accounts_4000"] = total_accounts_4000
    total_result["total_accounts_5000"] = total_accounts_5000
    total_result["total_accounts_6000"] = total_accounts_6000
    total_result["total_accounts_7000"] = total_accounts_7000
    total_result["total_accounts_8000"] = total_accounts_8000
    total_result["total_accounts_9000"] = total_accounts_9000
    total_result["total_revenue"] = total_accounts_3000 + total_accounts_4000
    total_result["total_expenses"] = total_accounts_5000 + total_accounts_6000 + total_accounts_7000
    total_result["total_diff"] = total_result["total_revenue"] + total_result["total_expenses"]
    total_result["total_result"] = total_accounts_8000 + total_result["total_diff"]

    return balance, total_balance, result, total_result
  end

  def set_number
    if self.number != nil
      return
    end
    puts "Journal type for #{self}: #{journal_type}"
    self.number = self.journal_type.get_next_number(self.company)
  end

end