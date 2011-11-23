
class DbStoredProcedure < ActiveRecord::Base

  #Method returning many rows
  def self.fetch_db_records(proc_name_with_parameters)
    connection.select_all(proc_name_with_parameters)
  end

  #Method altering the data
  def self.insert_update_delete_calculate(proc_name_with_parameters)
    connection.execute(proc_name_with_parameters)
  end

  #Method returning a value
  def self.fetch_val_from_sp(proc_name_with_parameters)
    connection.select_value(proc_name_with_parameters)
  end

end
