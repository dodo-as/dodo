
    -- create account row type for returning
    DROP TYPE IF EXISTS  acc ;
    CREATE TYPE acc AS (acc_id int, acc_number int, acc_amount real);
    -- acc_number = 0 => accounts total


    CREATE OR REPLACE FUNCTION report_balance(
                            is_result_report boolean ,
                            company int ,
                            car int,
                            unit int,
                            project int,
                            journal_type int,
                            periods_to_balance TEXT)
    RETURNS setof acc AS $$
    DECLARE
			period_balance acc;
                        total_balance real ;
                        sum_value real ;
			accountRecord record;
			journalRecord record;
			journalOperationRecord record;

          --declarations goes here
    BEGIN

                

                total_balance := 0;
		FOR accountRecord IN
					SELECT * FROM accounts
					WHERE accounts.company_id = company
					AND accounts.is_result_account = is_result_report
					ORDER BY accounts.number
		LOOP

                        

                        --calculating period balance
			IF (periods_to_balance IS NOT NULL AND LENGTH(periods_to_balance) > 0) THEN
                                sum_value := 0;
				FOR journalRecord IN
						SELECT * FROM journals
						Where journals.company_id = company
                                                AND journals.period_id = ANY (CAST (string_to_array(periods_to_balance, ',') AS int[] ))
                                                --PROBLEMS WITH CONDITIONAL FILTERING
                                                AND ( journal_type IS NULL OR journals.journal_type_id = journal_type )
				LOOP

                                                
        					FOR journalOperationRecord IN
							SELECT * FROM journal_operations
							WHERE journal_operations.account_id = accountRecord.id
							AND   journal_operations.journal_id =  journalRecord.id
                                                        --PROBLEMS WITH CONDITIONAL FILTERING
							AND   (car IS NULL OR journal_operations.car_id = car)
                                                        AND   (project IS NULL OR journal_operations.project_id = project)
                                                        AND   (unit IS NULL OR journal_operations.unit_id = unit)
                                                        AND   (project IS NULL OR journal_operations.project_id = project)
						LOOP
							IF journalOperationRecord.amount IS NOT NULL THEN
                                                            sum_value := sum_value + journalOperationRecord.amount ;
							END IF;
							
						END LOOP;
						
				END LOOP;

                                period_balance.acc_id := accountRecord.id;
                                period_balance.acc_number := accountRecord.number;
                                period_balance.acc_amount := sum_value;

                                RETURN NEXT period_balance;
                                total_balance := total_balance + sum_value;
			END IF;

		END LOOP;

                period_balance.acc_id := 0;
                period_balance.acc_number := 0;
                period_balance.acc_amount := total_balance;
        
        RETURN NEXT  period_balance;
    END;
    $$ LANGUAGE plpgsql;  