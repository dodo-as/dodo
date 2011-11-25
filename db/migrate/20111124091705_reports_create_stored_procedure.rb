class ReportsCreateStoredProcedure < ActiveRecord::Migration

  def self.up
    procedure_creation = File.read("db/stored_procedures.sql")
    ActiveRecord::Base.connection.execute("#{procedure_creation}")
  end

  def self.down
    ActiveRecord::Base.connection.execute("    DROP FUNCTION IF EXISTS report_balance(
                            is_result_report boolean ,
                            company int ,
                            car int,
                            unit int,
                            project int,
                            journal_type int,
                            periods_to_balance TEXT ) ;")
    ActiveRecord::Base.connection.execute(" DROP TYPE IF EXISTS  acc ;")
  end

end
