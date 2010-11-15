class ReportsController < ApplicationController
  
  def index
    @periods = Period.all(:limit=>20)
    @units = Unit.all(:limit=>20)
    @projects = Project.all(:limit=>20)
    @journal_types = JournalType.all(:limit=>20)
    @accounts = Account.all(:limit=>20)
  end

  def ledger_balance
    
    from_period = Period.find(params[:from_period_id]) unless params[:from_period_id].blank?
    to_period = Period.find(params[:to_period_id]) unless params[:to_period_id].blank?
    from_period_result_accounts = Period.find(params[:result_from_period_id]) unless params[:result_from_period_id].blank?

    @unit = Unit.find(params[:unit_id]) unless params[:unit_id].blank?    
    @project = Project.find(params[:project_id]) unless params[:project_id].blank?
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
    balance_previous_to_nr = balance_to_nr-1 unless balance_to_nr.blank?

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
                        :to_year=>balance_last_from_year, :to_nr=>balance_from_nr})

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

    @balance, @total_balance, @result = 
            Journal.report_ledger_balance(periods_to_balance, 
                                          periods_to_balance_previous,
                                          periods_to_balance_last,
                                          periods_to_balance_last_previous,  
                                          periods_to_result, 
                                          periods_to_result_last,
                                          current_user.current_company, 
                                          @unit, @project, @show_last_period)
    
  end

end
