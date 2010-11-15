require 'benchmark'

class ReportsController < ApplicationController

  def index
    @periods = Period.with_permissions_to(:index).order('year, nr')
    @units = Unit.with_permissions_to(:index)
    @projects = Project.with_permissions_to(:index)
    @journal_types = JournalType.with_permissions_to(:index).order('name')
    @accounts = Account.with_permissions_to(:index).order('number')
  end

  def ledger_journal
    
    accounts = nil
    periods = nil
    journal_operations = nil
    params[:offset] ||= 0    
    
    @journal_operations = []
    @count = 0;
    where = nil
    if !params[:from_account_number].blank? && !params[:to_account_number].blank?
      where = ["number BETWEEN ? AND ?", params[:from_account_number], params[:to_account_number]]
    elsif !params[:from_account_number].blank?
      where = ["number >= ?", params[:from_account_number]]
    elsif !params[:to_account_number].blank?
      where = ["number <= ?", params[:to_account_number]]
    end

    if where.nil?
      where = ["is_result_account = ?"]
    else 
      where[0] += " AND is_result_account = ?"
    end
    where << false
      
    accounts = Account.with_permissions_to(:read).where( where )
    
    where[where.length - 1] = true
    result_accounts = Account.with_permissions_to(:read).where( where )
    
    from_period = params[:from_period_id].blank? ? nil : Period.find(params[:from_period_id])
    to_period = params[:to_period_id].blank? ? nil : Period.find(params[:to_period_id])    
    from_year = from_period.nil? ? nil : from_period.year
    to_year = to_period.nil? ? nil : to_period.year
    from_nr = from_period.nil? ? nil : from_period.nr
    to_nr = to_period.nil? ? nil : to_period.nr
    
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
          page.<< "jQuery('#data').append( '#{escape_javascript(render(:partial=>'ledger_journal_data'))}' )"
        end
      }
      format.xml  { render :xml => @unit }
    end

    
  end

end
