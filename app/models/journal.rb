class Journal < ActiveRecord::Base
  has_many :journal_operations, :autosave => true
  belongs_to :company
  belongs_to :bill
  belongs_to :period

  belongs_to :journal_type

  scope :company, lambda {|company_id| where("company_id = ?", company_id)}
  scope :in_periods, lambda {|periods| where("period_id in (#{periods})")}

  def self.journal_type(journal_type)
    if journal_type
      where("journal_type_id = #{journal_type.id}")
    else
      scoped
    end
  end

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

  def self.report_ledger_balance(periods, company, unit, project,car, show_only_active_accounts,show_last_year,journal_type)

         #prepare filters for sql procedure
         company_id = company.blank? ? 'null' : "#{company.id}"
         car_id = car.blank? ? 'null' : "#{car.id}"
         unit_id = unit.blank? ? 'null' : "#{unit.id}"
         project_id = project.blank? ? 'null' : "#{project.id}"
         journal_type_id = journal_type.blank? ? 'null' : "#{journal_type.id}"
 
        _balance = "#{periods[:periods_to_balance].blank? ? 'null' : "'#{periods[:periods_to_balance]}'"}"
        _balance_previous = "#{periods[:periods_to_balance_previous].blank? ? 'null' : "'#{periods[:periods_to_balance_previous]}'"}"
        _balance_last = "#{periods[:periods_to_balance_last].blank? ? 'null' : "'#{periods[:periods_to_balance_last]}'"}"
        _balance_last_previous = "#{periods[:periods_to_balance_last_previous].blank? ? 'null' : "'#{periods[:periods_to_balance_last_previous]}'"}"
        _result = "#{periods[:periods_to_result].blank? ? 'null' : "'#{periods[:periods_to_result]}'"}"
        _result_previous = "#{periods[:periods_to_result_previous].blank? ? 'null' : "'#{periods[:periods_to_result_previous]}'"}"
        _result_last = "#{periods[:periods_to_result_last].blank? ? 'null' : "'#{periods[:periods_to_result_last]}'"}"
        _result_last_previous = "#{periods[:periods_to_result_previous_last].blank? ? 'null' : "'#{periods[:periods_to_result_last_previous]}'"}"


      #calculate each of the column with DbStoredProcedure report_balance
      #Balance Accounts report part
      balance = DbStoredProcedure.fetch_db_records("report_balance(false, #{show_last_year},#{show_only_active_accounts},#{company_id},#{car_id},#{unit_id},#{project_id},#{journal_type_id},#{_balance},#{_balance_previous},#{_balance_last},#{_balance_last_previous})")
      #Result Accounts report part
      result = DbStoredProcedure.fetch_db_records("report_balance(true, #{show_last_year},#{show_only_active_accounts},#{company_id},#{car_id},#{unit_id},#{project_id},#{journal_type_id},#{_result},#{_result_previous},#{_result_last},#{_result_last_previous})")


    total_accounts = Hash.new
    total_accounts["1000"] = 0
    total_accounts["2000"] = 0
    total_accounts["3000"] = 0
    total_accounts["4000"] = 0
    total_accounts["5000"] = 0
    total_accounts["6000"] = 0
    total_accounts["7000"] = 0
    total_accounts["8000"] = 0
    total_accounts["9000"] = 0

    balance.each do |row|
      case row["acc_number"].to_i
      when 1000..1999 then total_accounts["1000"] += row["acc_nb"].to_f
      when 2000..2999 then total_accounts["2000"] += row["acc_nb"].to_f
      end
    end

    result.each do |row|
      case row["acc_number"].to_i
        when 3000..3999 then total_accounts["3000"] += row["acc_nb"].to_f
        when 4000..4999 then total_accounts["4000"] += row["acc_nb"].to_f
        when 5000..5999 then total_accounts["5000"] += row["acc_nb"].to_f
        when 6000..6999 then total_accounts["6000"] += row["acc_nb"].to_f
        when 7000..7999 then total_accounts["7000"] += row["acc_nb"].to_f
        when 8000..8999 then total_accounts["8000"] += row["acc_nb"].to_f
        when 9000..9999 then total_accounts["9000"] += row["acc_nb"].to_f
      end
    end


    total_accounts["total_revenue"] = total_accounts["3000"] + total_accounts["4000"]
    total_accounts["total_expenses"] = total_accounts["5000"] + total_accounts["6000"] + total_accounts["7000"]
    total_accounts["total_diff"] = total_accounts["total_revenue"] + total_accounts["total_expenses"]
    total_accounts["total_result"] = total_accounts["8000"] + total_accounts["total_diff"]

    return balance, result, total_accounts

  end

  def set_number
    if self.number != nil
      return
    end
    puts "Journal type for #{self}: #{journal_type}"
    self.number = self.journal_type.get_next_number(self.company)
  end

end