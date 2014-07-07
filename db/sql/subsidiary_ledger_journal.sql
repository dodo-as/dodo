
-- create account row type for returning
    CREATE TYPE ledgjo   AS  (ledgid int, pid int, jdate date, oldb real, balance real, newb real,jtype int, jid int, jnumber int,jkid varchar, jbill varchar, status int);

    CREATE OR REPLACE FUNCTION report_subsidiary_ledger_journal(
                                                car int,
                                                unit int,
                                                project int,
                                                journal_type int,
                                                from_ledger int,
                                                to_ledger int,
                                                ledger_account int,
                                                balance_periods TEXT,
                                                previous_periods TEXT    )
    RETURNS setof ledgjo AS $$
    DECLARE
            ledgerRecord record;
            temp record;
            ledgjo_row ledgjo;

            old_balance real;
            

    BEGIN

              FOR ledgerRecord IN
					SELECT * FROM ledgers
                                        WHERE ledgers.account_id = ledger_account
                                        AND (from_ledger IS NULL OR ledgers.number >= from_ledger)
                                        AND (to_ledger IS NULL OR ledgers.number <= to_ledger)
					ORDER BY ledgers.number
              LOOP


              --previous balance
              old_balance := 0;
              IF (previous_periods IS NOT NULL AND LENGTH(previous_periods) > 0 ) THEN
                        SELECT SUM(jo.amount)
                        INTO old_balance
                        FROM  (journal_operations as jo
                        JOIN journals as j (journal_id) USING (journal_id) )
                        WHERE   jo.ledger_id  = ledgerRecord.id
                        AND   jo.amount IS NOT NULL
                        AND  j.period_id = ANY (CAST (string_to_array(previous_periods, ',') AS int[] ))
                        AND   (car IS NULL OR jo.car_id = car)
                        AND   (project IS NULL OR jo.project_id = project)
                        AND   (unit IS NULL OR jo.unit_id = unit)
                        AND   (journal_type IS NULL OR j.journal_type_id = journal_type);
              END IF;

              IF old_balance IS NULL THEN
                    old_balance := 0;
              END IF ;

             --current ledger journal operations
              IF (balance_periods IS NOT NULL AND LENGTH(balance_periods) > 0) THEN

                        FOR temp IN
                            SELECT j.period_id AS pid,
                            j.journal_date AS jdate,
                            jo.amount AS balance,
                            j.journal_id AS jid,
                            j.number AS jnumber,
                            j.kid AS jkid,
                            j.bill_number AS jbill,
                            j.journal_type_id AS jtype,
                            jo.closed_operation_id as status
                            FROM  (journal_operations as jo
                            JOIN journals as j (journal_id) USING (journal_id)
                            JOIN periods as p (period_id) USING (period_id)    )
                            WHERE (car IS NULL OR jo.car_id = car)
                            AND   (project IS NULL OR jo.project_id = project)
                            AND   (unit IS NULL OR jo.unit_id = unit)
                            AND   (journal_type IS NULL OR j.journal_type_id = journal_type)
                            AND   jo.ledger_id  = ledgerRecord.id
                            AND   jo.amount IS NOT NULL
                            AND   j.period_id = ANY (CAST (string_to_array(balance_periods, ',') AS int[] ))
                            ORDER BY p.year,p.nr,j.journal_date

                        LOOP

                            ledgjo_row.jkid := temp.jkid;
                            ledgjo_row.jbill := temp.jbill;
                            ledgjo_row.ledgid := ledgerRecord.id;
                            ledgjo_row.pid := temp.pid;
                            ledgjo_row.jdate := temp.jdate;
                            ledgjo_row.balance := temp.balance;
                            ledgjo_row.jid := temp.jid;
                            ledgjo_row.jnumber := temp.jnumber;
                            ledgjo_row.jtype := temp.jtype;
                            ledgjo_row.status := temp.status ;

                            ledgjo_row.oldb := old_balance;
                            ledgjo_row.newb := ledgjo_row.oldb + ledgjo_row.balance;
                            old_balance := ledgjo_row.newb;

                            RETURN NEXT ledgjo_row;

                        END LOOP;
                END IF;


              END LOOP;              

    END;
    $$ LANGUAGE plpgsql;