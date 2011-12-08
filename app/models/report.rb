class Report < ActiveRecord::Base


  def self.report_ledger_journal(periods,from_account_number,to_account_number,company,car,unit,project,journal_type)

    #prepare filters for sql procedure
      comp_id = company.blank? ? 'null' : "#{company.id}"
      car_id = car.blank? ? 'null' : "#{car.id}"
      unit_id = unit.blank? ? 'null' : "#{unit.id}"
      project_id = project.blank? ? 'null' : "#{project.id}"
      j_type_id = journal_type.blank? ? 'null' : "#{journal_type.id}"

      _f_number = from_account_number.blank? ? 'null': from_account_number.to_i
      _t_number = to_account_number.blank? ? 'null' : to_account_number.to_i

      _balance = "#{periods[:periods_to_balance].blank? ? 'null' : "'#{periods[:periods_to_balance]}'"}"
      _balance_previous = "#{periods[:periods_to_balance_previous].blank? ? 'null' : "'#{periods[:periods_to_balance_previous]}'"}"
      _result_previous = "#{periods[:periods_to_result_previous].blank? ? 'null' : "'#{periods[:periods_to_result_previous]}'"}"


    journal_operations = DbStoredProcedure.fetch_db_records("report_ledger_journal(#{comp_id},#{car_id},#{unit_id},#{project_id},#{j_type_id},#{_f_number},#{_t_number},#{_balance},#{_balance_previous},#{_result_previous})")
    return journal_operations
  end

  def self.report_subsidiary_ledger_balance(periods,ledger_account,from_ledger,to_ledger,car,unit,project,journal_type,show_only_active_accounts)
      #prepare filters for sql procedure
      car_id = car.blank? ? 'null' : "#{car.id}"
      unit_id = unit.blank? ? 'null' : "#{unit.id}"
      project_id = project.blank? ? 'null' : "#{project.id}"
      j_type_id = journal_type.blank? ? 'null' : "#{journal_type.id}"

      _from_ledger = from_ledger.blank? ? 'null': from_ledger.number
      _to_ledger = to_ledger.blank? ? 'null' : to_ledger.id.number
      _ledger_account = ledger_account.blank? ? 'null' : ledger_account.id

      _periods = "#{periods[:periods_to_balance].blank? ? 'null' : "'#{periods[:periods_to_balance]}'" }"
      _previous_periods = "#{periods[:periods_to_result_previous].blank? ? 'null' : "'#{periods[:periods_to_result_previous]}'"}"

    result = DbStoredProcedure.fetch_db_records("report_subsidiary_ledger_balance(#{show_only_active_accounts},#{car_id},#{unit_id},#{project_id},#{j_type_id},#{_from_ledger},#{_to_ledger},#{_ledger_account},#{_periods},#{_previous_periods})")
    return result
  end

  def self.report_subsidiary_ledger_journal(periods,ledger_account,from_ledger,to_ledger,car,unit,project,journal_type)
    #prepare filters for sql procedure
      car_id = car.blank? ? 'null' : "#{car.id}"
      unit_id = unit.blank? ? 'null' : "#{unit.id}"
      project_id = project.blank? ? 'null' : "#{project.id}"
      j_type_id = journal_type.blank? ? 'null' : "#{journal_type.id}"

      _from_ledger = from_ledger.blank? ? 'null': from_ledger.number
      _to_ledger = to_ledger.blank? ? 'null' : to_ledger.id.number
      _ledger_account = ledger_account.blank? ? 'null' : ledger_account.id

      _periods = "#{periods[:periods_to_balance].blank? ? 'null' : "'#{periods[:periods_to_balance]}'" }"
      _previous_periods = "#{periods[:periods_to_result_previous].blank? ? 'null' : "'#{periods[:periods_to_result_previous]}'"}"

      journal_operations = DbStoredProcedure.fetch_db_records("report_subsidiary_ledger_journal(#{car_id},#{unit_id},#{project_id},#{j_type_id},#{_from_ledger},#{_to_ledger},#{_ledger_account},#{_periods},#{_previous_periods})")
      return journal_operations
  end

end
