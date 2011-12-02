   -- create account row type for returning
    CREATE TYPE ledg AS (ledger_name varchar, ledger_number int, ledger_b real, ledger_pb real, ledger_nb real);

    CREATE OR REPLACE FUNCTION report_subsidiary_ledger_balance(  show_only_active_accounts boolean,
                                                car int,
                                                unit int,
                                                project int,
                                                journal_type int,
                                                from_ledger int,
                                                to_ledger int,
                                                ledger_account int,
                                                periods TEXT,
                                                previous_periods TEXT    )
    RETURNS setof ledg AS $$
    DECLARE
            ledgerRecord record;
            temp ledg;
            previous_balance real;
            balance real;
            new_balance real;
            total_previous real;
            total_balance real;
            total_new real;
            active boolean := false;
    BEGIN


              total_previous := 0;
              total_balance := 0 ;
              total_new := 0;

              FOR ledgerRecord IN
					SELECT * FROM ledgers
                                        WHERE ledgers.account_id = ledger_account
                                        AND (from_ledger IS NULL OR ledgers.number >= from_ledger)
                                        AND (to_ledger IS NULL OR ledgers.number <= to_ledger)
					ORDER BY ledgers.number
              LOOP

                        previous_balance := 0;
                        balance := 0;
                        new_balance := 0;

                        IF (previous_periods IS NOT NULL AND LENGTH(previous_periods) > 0 ) THEN
                            SELECT SUM(jo.amount)
                            INTO previous_balance
                            FROM  (journal_operations as jo
                            JOIN journals as j (journal_id) USING (journal_id) )
                            WHERE   jo.account_id  = ledger_account
                            AND     jo.ledger_id = ledgerRecord.id
                            AND     jo.amount IS NOT NULL
                            AND     j.period_id = ANY (CAST (string_to_array(previous_periods, ',') AS int[] ))
                            AND     (car IS NULL OR jo.car_id = car)
                            AND     (project IS NULL OR jo.project_id = project)
                            AND     (unit IS NULL OR jo.unit_id = unit)
                            AND     (journal_type IS NULL OR j.journal_type_id = journal_type);
                        END IF;


                        IF (periods IS NOT NULL AND LENGTH(periods) > 0 ) THEN
                            SELECT SUM(jo.amount)
                            INTO balance
                            FROM  (journal_operations as jo
                            JOIN journals as j (journal_id) USING (journal_id) )
                            WHERE   jo.account_id  = ledger_account
                            AND     jo.ledger_id = ledgerRecord.id
                            AND     jo.amount IS NOT NULL
                            AND     j.period_id = ANY (CAST (string_to_array(periods, ',') AS int[] ))
                            AND     (car IS NULL OR jo.car_id = car)
                            AND     (project IS NULL OR jo.project_id = project)
                            AND     (unit IS NULL OR jo.unit_id = unit)
                            AND     (journal_type IS NULL OR j.journal_type_id = journal_type);
                        END IF;

                        new_balance := previous_balance + balance;

                        total_balance := total_balance + balance;
                        total_previous := total_previous + previous_balance;
                        total_new := total_new + new_balance;

                        temp.ledger_name := ledgerRecord.name;
                        temp.ledger_number := ledgerRecord.number;
                        temp.ledger_b := balance ;
                        temp.ledger_pb := previous_balance ;
                        temp.ledger_nb := new_balance;

                        RETURN NEXT temp;

              END LOOP;

            --total row
            temp.ledger_name := 'total';
            temp.ledger_number := 0;
            temp.ledger_b := total_balance;
            temp.ledger_pb := total_previous ;
            temp.ledger_nb := total_balance;


    END;
    $$ LANGUAGE plpgsql;  
