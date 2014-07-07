class ReportsCreateLedgerJournal < ActiveRecord::Migration

  def self.up
    procedure_creation = File.read("db/sql/ledger_report_journal.sql")
    ActiveRecord::Base.connection.execute("#{procedure_creation}")
  end

  def self.down
    ActiveRecord::Base.connection.execute("DROP FUNCTION IF EXISTS report_ledger_journal(
                                                      company_id int,
                                                      car_id int,
                                                      unit_id int,
                                                      project_id int,
                                                      journal_type_id int,
                                                      from_number int,
                                                      to_number int,
                                                      balance_periods TEXT,
                                                      balance_previous_periods TEXT,
                                                      result_previous_periods TEXT
                                         );")

    ActiveRecord::Base.connection.execute("DROP TYPE IF EXISTS joperation ;")
  end

end
