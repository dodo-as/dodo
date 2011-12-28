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

  def result_from_date(options={})
    result_from = options[:period]
    title = ""
    unless result_from.blank?
      title = "#{t(:result_from_period,:scope => :reports)} #{result_from.year.to_s}-#{result_from.nr.to_s}"
    end
    title
  end

  def change_select_options_for_ledger(subsidiary_ledger_accounts)
    page = ""
            if subsidiary_ledger_accounts.blank?
            page << "$('.ledger_from')
                    .find('option')
                    .remove()
                    .end()
                    .append('<option value=\"\"></option>')
                    .val('');
                     $('.ledger_to')
                    .find('option')
                    .remove()
                    .end()
                    .append('<option value=\"\"></option>')
                    .val('');"
          else
            page << "$('.ledger_from')
                    .find('option')
                    .remove()
                    .end()"
                    page << ".append('<option value=\"\"></option>')"
                    subsidiary_ledger_accounts.each do |ledger|
                        page <<  ".append('<option value=\"#{ledger.id}\">#{ledger.to_s_with_number}</option>')"
                    end
                    page << ".val('#{subsidiary_ledger_accounts.first.id}')
                    ;"
            page << "$('.ledger_to')
                    .find('option')
                    .remove()
                    .end()"
                    page << ".append('<option value=\"\"></option>')"
                    subsidiary_ledger_accounts.each do |ledger|
                        page <<  ".append('<option value=\"#{ledger.id}\">#{ledger.to_s_with_number}</option>')"
                    end
                    page << ".val('#{subsidiary_ledger_accounts.last.id}')
                    ;"
          end
          page << "$(\'#loading_img\').hide();"
          return page
  end

  def jtype(id)
    JournalType.find(id).abbreviation unless id.blank?
  end

  def unit(id)
    jo = JournalOperation.find(id)
    jo.unit.to_s unless jo.unit_id.blank?
  end

  def project(id)
    jo = JournalOperation.find(id)
    jo.project.to_s unless jo.project_id.blank?
  end

  def car(id)
    jo = JournalOperation.find(id)
    jo.car.to_s unless jo.car_id.blank?
  end

  def closed_by(closed_op_id)
    JournalOperation.where(:closed_operation_id => closed_op_id).first.closed_operation.matched_by.to_s
  end
  
end