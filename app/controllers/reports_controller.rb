require 'benchmark'

class ReportsController < ApplicationController

  def index
    @periods = Period.with_permissions_to(:index).order('year, nr').reverse
    @units = Unit.with_permissions_to(:index)
    @projects = Project.with_permissions_to(:index)
    @cars = Car.with_permissions_to(:index)
    @journal_types = JournalType.with_permissions_to(:index).order('name')
    @accounts = Account.with_permissions_to(:index).order('number')
  end

  def ledger_balance
    
    from_period = Period.find(params[:from_period_id]) unless params[:from_period_id].blank?
    to_period = Period.find(params[:to_period_id]) unless params[:to_period_id].blank?
    from_period_result_accounts = Period.find(params[:result_from_period_id]) unless params[:result_from_period_id].blank?

    @unit = Unit.find(params[:unit_id]) unless params[:unit_id].blank?    
    @project = Project.find(params[:project_id]) unless params[:project_id].blank?
    @car = Car.find(params[:car_id]) unless params[:car_id].blank?
    @journal_type = JournalType.find(params[:journal_type_id]) unless params[:journal_type_id].blank?
    
    @show_only_active_accounts = params[:show_only_active_accounts]
    @show_last_period = params[:last_year_figures]

    balance_from_year = nil
    balance_from_nr = nil
    balance_to_year = nil
    balance_to_nr = nil
    balance_previous_to_year = nil
    balance_previous_to_nr = nil
    balance_last_from_year = nil
    balance_last_to_year = nil
    balance_last_previous_to_year = nil
    balance_last_previous_to_nr = nil

    balance_from_year = from_period.year unless from_period.blank?
    balance_from_nr = from_period.nr unless from_period.blank?

    balance_to_year = to_period.year unless to_period.blank?
    balance_to_nr = to_period.nr unless to_period.blank?

    balance_previous_to_year = balance_to_year unless balance_to_year.blank?
    balance_previous_to_nr = balance_from_nr-1 unless balance_from_nr.blank?

    balance_last_from_year = from_period.year-1 unless from_period.blank?
    balance_last_to_year = to_period.year-1 unless to_period.blank?

    balance_last_previous_to_year = balance_last_from_year unless balance_last_from_year.blank?
    balance_last_previous_to_nr = balance_from_nr-1 unless balance_from_nr.blank?

#    balance_before_last_from_year = from_period.year-2 unless from_period.blank?
#    balance_before_last_to_year = to_period.year-2 unless to_period.blank?

    result_from_year = from_period_result_accounts.year unless from_period_result_accounts.blank?
    result_from_nr = from_period_result_accounts.nr unless from_period_result_accounts.blank?
    result_last_from_year = from_period_result_accounts.year-1 unless from_period_result_accounts.blank?

    puts "va sacar el ramgo periods_to_balance"
    periods_to_balance = Period.get_range(current_user.current_company.id, 
                        {:from_year=>balance_from_year, :from_nr=>balance_from_nr, 
                        :to_year=>balance_to_year, :to_nr=>balance_to_nr})
    if periods_to_balance.blank?
      @first_period_to_balance = nil
      @last_period_to_balance =  nil
    else
      @first_period_to_balance = periods_to_balance.first
      @last_period_to_balance =  periods_to_balance.last
    end

    periods_to_balance_previous = Period.get_range(current_user.current_company.id, 
                        {:from_year=>nil, :from_nr=>nil, 
                        :to_year=>balance_previous_to_year, :to_nr=>balance_previous_to_nr})

    periods_to_balance_last = Period.get_range(current_user.current_company.id, 
                        {:from_year=>balance_last_from_year, :from_nr=>balance_from_nr, 
                        :to_year=>balance_last_to_year, :to_nr=>balance_to_nr})

    if periods_to_balance_last.blank?
      @first_period_to_balance_last = nil
      @last_period_to_balance_last = nil      
    else
      @first_period_to_balance_last = periods_to_balance_last.first
      @last_period_to_balance_last = periods_to_balance_last.last
    end

    periods_to_balance_last_previous = Period.get_range(current_user.current_company.id, 
                        {:from_year=>nil, :from_nr=>nil, 
                        :to_year=>balance_last_previous_to_year, :to_nr=>balance_last_previous_to_nr})

   # periods_to_balance_before_last = Period.get_range(current_user.current_company.id, 
   #                     {:from_year=>balance_before_last_from_year, :from_nr=>balance_from_nr, 
   #                     :to_year=>balance_before_last_to_year, :to_nr=>balance_to_nr})

    periods_to_result = Period.get_range(current_user.current_company.id, 
                        {:from_year=>result_from_year, :from_nr=>result_from_nr, 
                        :to_year=>balance_to_year, :to_nr=>balance_to_nr})

    if periods_to_result.blank?
      @first_period_to_result = nil
      @last_period_to_result = nil
    else  
      @first_period_to_result = periods_to_result.first
      @last_period_to_result = periods_to_result.last
    end

    periods_to_result_last = Period.get_range(current_user.current_company.id, 
                        {:from_year=>result_last_from_year, :from_nr=>result_from_nr, 
                       :to_year=>balance_last_to_year, :to_nr=>balance_to_nr})

    if periods_to_result_last.blank?
      @first_period_to_result_last = nil 
      @last_period_to_result_last = nil
    else
      @first_period_to_result_last = periods_to_result_last.first
      @last_period_to_result_last = periods_to_result_last.last
    end

#    puts "========== periods to balance "
#    periods_to_balance.each do |p|
#      puts "year " + p.year.to_s
#      puts "nr " + p.nr.to_s
#    end
#    puts "========== periods to balance previous "
#    periods_to_balance_previous.each do |p|
#      puts "year " + p.year.to_s
#      puts "nr " + p.nr.to_s
#    end
#
#    puts "========== periods to balance last "
#    periods_to_balance_last.each do |p|
#      puts "year " + p.year.to_s
#      puts "nr " + p.nr.to_s
#    end
#
#    puts "========== periods to balance last previous"
#    periods_to_balance_last_previous.each do |p|
#      puts "year " + p.year.to_s
#      puts "nr " + p.nr.to_s
#    end
#
#    puts "========== periods to result"
#    periods_to_result.each do |p|
#      puts "year " + p.year.to_s
#      puts "nr " + p.nr.to_s
#    end
#
#    puts "========== periods to result last"
#    periods_to_result_last.each do |p|
#      puts "year " + p.year.to_s
#      puts "nr " + p.nr.to_s
#    end

    @balance, @total_balance, @result, @total_result = 
            Journal.report_ledger_balance(periods_to_balance, 
                                          periods_to_balance_previous,
                                          periods_to_balance_last,
                                          periods_to_balance_last_previous,  
                                          periods_to_result, 
                                          periods_to_result_last,
                                          current_user.current_company, 
                                          @unit, @project,@car,
                                          @show_only_active_accounts)

  end

  def ledger_journal
 
    accounts = nil
    periods = nil
    params[:offset] ||= 0    
    
    @journal_operations = []
    @count = 0;
    where = nil
    #if specified accounts range is taken between from_account_number and to_account_number
    if !params[:from_account_number].blank? && !params[:to_account_number].blank?
      where = ["number BETWEEN ? AND ?", params[:from_account_number], params[:to_account_number]]
    elsif !params[:from_account_number].blank?
      #from_account specified but not to_account
      where = ["number >= ?", params[:from_account_number]]
    elsif !params[:to_account_number].blank?
      #to_account specified but not from_account
      where = ["number <= ?", params[:to_account_number]]
    end
    
    if where.nil?
      #if no accounts specified
      where = ["is_result_account = ?"]
    else
      #if one of the accounts at least is specified
      where[0] += " AND is_result_account = ?"
    end
    where << false
      
    accounts = Account.with_permissions_to(:read).where( where )
    
    where[where.length - 1] = true
    result_accounts = Account.with_permissions_to(:read).where( where )
    
    @from_period = params[:from_period_id].blank? ? nil : Period.find(params[:from_period_id])
    @to_period = params[:to_period_id].blank? ? nil : Period.find(params[:to_period_id])    
    from_year = @from_period.nil? ? nil : @from_period.year
    to_year = @to_period.nil? ? nil : @to_period.year
    from_nr = @from_period.nil? ? nil : @from_period.nr
    to_nr = @to_period.nil? ? nil : @to_period.nr
    
    result_from_period = params[:result_from_period_id].blank? ? nil : Period.find(params[:result_from_period_id])
    result_from_year = result_from_period.nil? ? nil : result_from_period.year
    result_from_nr = result_from_period.nil? ? nil : result_from_period.nr
    
    periods = Period.get_range(current_user.current_company.id, 
      :from_year=>from_year, :from_nr=>from_nr, :to_year=>to_year, :to_nr=>to_nr)  
      
    result_periods = Period.get_range(current_user.current_company.id, 
      :from_year=>result_from_year, :from_nr=>result_from_nr, :to_year=>to_year, :to_nr=>to_nr)  

    unless (periods.empty? and result_periods.empty?) or ( accounts.empty? and result_accounts.empty? )
      _accounts = accounts.collect { |a| a.id }.join(",")
      _periods = periods.collect { |p| p.id }.join(",")
      _result_accounts = result_accounts.collect { |a| a.id }.join(",")
      _result_periods = result_periods.collect { |p| p.id }.join(",")
      where = ["((accounts.is_result_account = false AND account_id IN (#{_accounts}) AND journals.period_id IN (#{_periods}))"]
      if _result_accounts.blank? or _result_periods.blank?
        where[0] += ")"
      else
        where[0] += " OR (accounts.is_result_account = true AND account_id IN (#{_result_accounts}) AND journals.period_id IN (#{_result_periods})))"
      end
      unless params[:journal_type_id].blank?
        where[0] += " AND journal_type_id = ?"
        where << params[:journal_type_id]
      end
      unless params[:project_id].blank?
        where[0] += " AND project_id = ?"
        where << params[:project_id]
      end
      unless params[:unit_id].blank?
        where[0] += " AND unit_id = ?"
        where << params[:unit_id]
      end
      unless params[:car_id].blank?
        where[0] += " AND car_id = ?"
      end

      @journal_operations = JournalOperation.joins(:journal).joins(:account).where(where).order(
        "account_id, journals.period_id, journal_operations.created_at").includes(
        :journal, :account).limit(500).offset(params[:offset])

      if params[:offset]==0
        @count = JournalOperation.count(
          :joins=>" INNER JOIN journals ON journal_operations.journal_id = journals.id 
                    INNER JOIN accounts ON journal_operations.account_id = accounts.id",
          :conditions=>where)
      end
    end
    
    respond_to do |format|
      format.html
      format.js {
        render :update do |page|
          page.<< "jQuery('tbody#data').append( '#{escape_javascript(render(:partial=>'ledger_journal_data', :locals=>{:params=>params}))}' )"
        end
      }
      format.xml  { render :xml => @unit }
    end
    
  end

end
