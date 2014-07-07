class ReportsCreateLedgerBalanceProc < ActiveRecord::Migration

  def self.up
    procedure_creation = File.read("db/sql/ledger_report_balance.sql")
    ActiveRecord::Base.connection.execute("#{procedure_creation}")
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP FUNCTION IF EXISTS report_balance(
                            is_result_report boolean ,
                            show_last_year boolean,
                            show_only_active_accounts boolean,
                            company int ,
                            car int,
                            unit int,
                            project int,
                            journal_type int,
                            periods_to_balance TEXT ,
                            periods_to_balance_previous TEXT,
                            periods_to_balance_last TEXT,
                            periods_to_balance_last_previous TEXT ) ;")
    
    ActiveRecord::Base.connection.execute(" DROP TYPE IF EXISTS  acc ;")

    ActiveRecord::Base.connection.execute(" DROP LANGUAGE IF EXISTS plpgsql;")
    
  end

end
