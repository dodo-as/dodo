class ReportsCreateSubsidiaryLedgerJournalProc < ActiveRecord::Migration
  
  
  def self.up
    procedure_creation = File.read("db/sql/subsidiary_ledger_journal.sql")
    ActiveRecord::Base.connection.execute("#{procedure_creation}")
  end

  def self.down
      ActiveRecord::Base.connection.execute("DROP FUNCTION report_subsidiary_ledger_journal(
                                                car int,
                                                unit int,
                                                project int,
                                                journal_type int,
                                                from_ledger int,
                                                to_ledger int,
                                                ledger_account int,
                                                periods TEXT,
                                                previous_periods TEXT    );")

    ActiveRecord::Base.connection.execute("DROP TYPE ledgjo ;")
  end

end
