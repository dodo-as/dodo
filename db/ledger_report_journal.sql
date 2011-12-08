    
    -- create account row type for returning
    CREATE TYPE joperation AS (accid int, pid int, jdate date, oldb real, balance real, newb real, jid int, jnumber int);


    CREATE OR REPLACE FUNCTION report_ledger_journal( company int,
                                                      car int,
                                                      unit int,
                                                      project int,
                                                      journal_type int,
                                                      from_number int,
                                                      to_number int,
                                                      balance_periods TEXT,
                                                      balance_previous_periods TEXT,
                                                      result_previous_periods TEXT)
    RETURNS setof joperation AS $$

    DECLARE
            accountRecord record;
            jo_row joperation;
            temp record;
            old_balance real:=0;
            
    BEGIN


            
            FOR accountRecord IN
					SELECT * FROM accounts
					WHERE accounts.company_id = company
                                        AND ( from_number IS NULL OR accounts.number >= from_number)
                                        AND ( to_number IS NULL OR accounts.number <= to_number)
					ORDER BY accounts.number
            LOOP
                old_balance := 0;
                --previous balance depending on account type (balance or result)
                IF (accountRecord.is_result_account) THEN
                    IF (result_previous_periods IS NOT NULL AND LENGTH(result_previous_periods) > 0 ) THEN
                        SELECT SUM(jo.amount)
                        INTO old_balance
                        FROM  (journal_operations as jo
                        JOIN journals as j (journal_id) USING (journal_id) )
                        WHERE   jo.account_id  = accountRecord.id
                        AND   jo.amount IS NOT NULL
                        AND  j.period_id = ANY (CAST (string_to_array(result_previous_periods, ',') AS int[] ))
                        AND (car IS NULL OR jo.car_id = car)
                        AND   (project IS NULL OR jo.project_id = project)
                        AND   (unit IS NULL OR jo.unit_id = unit)
                        AND   (journal_type IS NULL OR j.journal_type_id = journal_type);
                    END IF;
                ELSE
                    IF (balance_previous_periods IS NOT NULL AND LENGTH(balance_previous_periods) > 0 ) THEN
                        SELECT SUM(jo.amount)
                        INTO old_balance
                        FROM  (journal_operations as jo
                        JOIN journals as j (journal_id) USING (journal_id) )
                        WHERE   jo.account_id  = accountRecord.id
                        AND   jo.amount IS NOT NULL
                        AND  j.period_id = ANY (CAST (string_to_array(balance_previous_periods, ',') AS int[] ))
                        AND (car IS NULL OR jo.car_id = car)
                        AND   (project IS NULL OR jo.project_id = project)
                        AND   (unit IS NULL OR jo.unit_id = unit)
                        AND   (journal_type IS NULL OR j.journal_type_id = journal_type);
                    END IF;
                END IF;

                IF old_balance IS NULL THEN
                    old_balance := 0;
                END IF;

                --current account journal operations
                IF (balance_periods IS NOT NULL AND LENGTH(balance_periods) > 0) THEN
                   
                    FOR temp IN
                            SELECT  j.period_id AS pid,
                            j.journal_date AS jdate,
                            jo.amount AS balance,
                            j.journal_id AS jid,
                            j.number AS jnumber
                            FROM  (journal_operations as jo
                            JOIN journals as j (journal_id) USING (journal_id)
                            JOIN periods as p (period_id) USING (period_id)    )
                            WHERE (car IS NULL OR jo.car_id = car)
                            AND   (project IS NULL OR jo.project_id = project)
                            AND   (unit IS NULL OR jo.unit_id = unit)
                            AND   (journal_type IS NULL OR j.journal_type_id = journal_type)
                            AND   jo.account_id  = accountRecord.id
                            AND   jo.amount IS NOT NULL
                            AND   j.period_id = ANY (CAST (string_to_array(balance_periods, ',') AS int[] ))
                            ORDER BY p.year,p.nr,j.journal_date
                    LOOP

                            jo_row.accid := accountRecord.id;
                            jo_row.pid := temp.pid;
                            jo_row.jdate := temp.jdate;
                            jo_row.balance := temp.balance;
                            jo_row.jid := temp.jid;
                            jo_row.jnumber := temp.jnumber;

                            jo_row.oldb := old_balance;
                            jo_row.newb := jo_row.oldb + jo_row.balance;
                            old_balance := jo_row.newb;

                            RETURN NEXT jo_row;
                            
                    END LOOP;
                END IF;


            END LOOP;



    END;
    $$ LANGUAGE plpgsql;
