class ReportsCreateDagbokProc < ActiveRecord::Migration

  def self.up
    procedure_creation = File.read("db/dagbok_report.sql")
    ActiveRecord::Base.connection.execute("#{procedure_creation}")
  end

  def self.down
          ActiveRecord::Base.connection.execute("DROP FUNCTION report_dagbok(
                                              company int,
                                               from_date date,
                                               to_date date,
                                               from_period int,
                                               to_period int,
                                               from_account_number int,
                                               to_account_number int,
                                               from_journal_number int,
                                               to_journal_number int,
                                               filter_by_ledgers boolean,
                                               ledger_ids TEXT,
                                               unit int,
                                               project int,
                                               car int,
                                               journal_type int,
                                               mva_code varchar,
                                               mva_percentage real,
                                               description varchar,
                                               amount_from real,
                                               amount_to real,
                                               kid_from varchar,
                                               kid_to varchar,
                                               invoice_number_from varchar,
                                               invoice_number_to varchar,
                                               sorted_by varchar  );")

    ActiveRecord::Base.connection.execute("DROP TYPE dagbokop ;")
  end

end