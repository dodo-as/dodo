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
      _to_ledger = to_ledger.blank? ? 'null' : to_ledger.number
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
      _to_ledger = to_ledger.blank? ? 'null' : to_ledger.number
      _ledger_account = ledger_account.blank? ? 'null' : ledger_account.id

      _periods = "#{periods[:periods_to_balance].blank? ? 'null' : "'#{periods[:periods_to_balance]}'" }"
      _previous_periods = "#{periods[:periods_to_result_previous].blank? ? 'null' : "'#{periods[:periods_to_result_previous]}'"}"

      journal_operations = DbStoredProcedure.fetch_db_records("report_subsidiary_ledger_journal(#{car_id},#{unit_id},#{project_id},#{j_type_id},#{_from_ledger},#{_to_ledger},#{_ledger_account},#{_periods},#{_previous_periods})")
      return journal_operations
  end

  def self.report_dagbok(options,company)

      from_date = (options[:from_date].blank? or (! options[:from_date] =~ /\d{2}\-\d{2}\-\d{4}/)) ? 'null' : "'#{options[:from_date]}'"
      to_date = (options[:to_date].blank? or (! options[:to_date] =~ /\d{2}\-\d{2}\-\d{4}/)) ? 'null' : "'#{options[:to_date]}'"
      from_period = options[:from_period_id].blank? ? 'null' : "#{options[:from_period_id]}"
      to_period =   options[:to_period_id].blank?   ? 'null' : "#{options[:to_period_id]}"
      from_account_number = options[:from_account_number].blank? ? 'null' : "#{options[:from_account_number]}"
      to_account_number = options[:to_account_number].blank? ? 'null' : "#{options[:to_account_number]}"
      from_journal_number = ( options[:from_journal_number].blank? or (! options[:from_journal_number] =~ /[0-9]+/) ) ? 'null' : "#{options[:from_journal_number]}" #validate int
      to_journal_number = ( options[:to_journal_number].blank?  or (! options[:to_journal_number] =~ /[0-9]+/)) ? 'null' : "#{options[:to_journal_number]}" #validate int

      ledger_from = Ledger.find(options[:ledger_from_id]) unless options[:ledger_from_id].blank?
      ledger_to = Ledger.find(options[:ledger_to_id]) unless options[:ledger_to_id].blank?
      ledger_ids = Ledger.get_ids_of_range(ledger_from, ledger_to)
      filter_by_ledgers = ledger_from.blank? && ledger_to.blank? ? false : true
      ledger_ids = ledger_ids.blank? ? 'null' : "'#{ledger_ids.join(",")}'"

      unit = options[:unit_id].blank? ? 'null' : "#{options[:unit_id]}"
      project = options[:project_id].blank? ? 'null' : "#{options[:project_id]}"
      car = options[:car_id].blank? ? 'null' : "#{options[:car_id]}"
      journal_type = options[:journal_type_id].blank? ? 'null' : "#{options[:journal_type_id]}"
      mva_code = options[:mva_code].blank? ? 'null' : "'#{options[:mva_code]}'" #not important for now, doesnt exist in the database
      mva_percentage = options[:mva_percentage].blank? ? 'null' : "#{options[:mva_percentage]}" #not important for now, doesnt exist in the database

      text = options[:text].blank? ? 'null' : "'#{options[:text]}'"
      amount_from = (options[:amount_from].blank? or (! options[:amount_from] =~ /^[+-]?\d+??(?:\.\d{0,2})?$/) ) ? 'null' : "#{options[:amount_from]}"
      amount_to = (options[:amount_to].blank? or (! options[:amount_to] =~ /^[+-]?\d+??(?:\.\d{0,2})?$/) ) ? 'null' : "#{options[:amount_to]}"
      kid_from = options[:kid_from].blank? ? 'null' : "'#{options[:kid_from]}'" #determine how to do it
      kid_to = options[:kid_to].blank? ? 'null' : "'#{options[:kid_to]}'" #determine how to do it
      invoice_number_from = options[:invoice_number_from].blank? ? 'null' : "'#{options[:invoice_number_from]}'" #determine how to do it
      invoice_number_to = options[:invoice_number_to].blank? ? 'null' : "'#{options[:invoice_number_to]}'" #determine how to do it

      sorted_by = options[:sorted_by].blank? ? 'null' : "'#{options[:sort_by]}'"
                  func = "report_dagbok( #{company},"
                  func << "#{from_date},"
                  func << "#{to_date},"
                  func << "#{from_period},"
                  func << "#{to_period},"
                  func << "#{from_account_number},"
                  func << "#{to_account_number},"
                  func << "#{from_journal_number},"
                  func << "#{to_journal_number},"
                  func << "#{filter_by_ledgers},"
                  func << "#{ledger_ids},"
                  func << "#{unit},"
                  func << "#{project},"
                  func << "#{car},"
                  func << "#{journal_type},"
                  func << "#{mva_code},"
                  func << "#{mva_percentage},"
                  func << "#{text},"
                  func << "#{amount_from},"
                  func << "#{amount_to},"
                  func << "#{kid_from},"
                  func << "#{kid_to},"
                  func << "#{invoice_number_from},"
                  func << "#{invoice_number_to},"
                  func << "#{sorted_by})"
      journal_operations = DbStoredProcedure.fetch_db_records(func)

      return journal_operations,from_date,to_date,from_period,to_period,from_account_number,to_account_number,
             from_journal_number,to_journal_number,ledger_from,ledger_to,unit,project,car,journal_type,mva_code,
             mva_percentage,text,amount_from,amount_to,kid_from,kid_to,invoice_number_from,invoice_number_to,
             sorted_by


  end

end
