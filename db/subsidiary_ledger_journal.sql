
-- create account row type for returning
    CREATE TYPE ledgjo   AS  (ledgid int, pid int, jdate date, oldb real, balance real, newb real, jid int, jnumber int);

    CREATE OR REPLACE FUNCTION report_subsidiary_ledger_journal(
                                                car int,
                                                unit int,
                                                project int,
                                                journal_type int,
                                                from_ledger int,
                                                to_ledger int,
                                                ledger_account int,
                                                periods TEXT,
                                                previous_periods TEXT    )
    RETURNS setof ledgjo AS $$
    DECLARE


    BEGIN


    END;
    $$ LANGUAGE plpgsql;