
    -- create language plpgsql for all stored procedures
    CREATE OR REPLACE FUNCTION create_language_plpgsql()
    RETURNS BOOLEAN AS $$
            CREATE LANGUAGE plpgsql;
            SELECT TRUE;
            $$ LANGUAGE SQL;

    SELECT CASE WHEN NOT
    (
        SELECT  TRUE AS exists
        FROM    pg_language
        WHERE   lanname = 'plpgsql'
        UNION
        SELECT  FALSE AS exists
        ORDER BY exists DESC
        LIMIT 1
    )
    THEN
        create_language_plpgsql()
    ELSE
        FALSE
    END AS plpgsql_created;

    -- we no longer need this function
    DROP FUNCTION create_language_plpgsql();
    -- end of  create language section

    -- create account row type for returning
    CREATE TYPE acc AS (acc_name varchar, acc_number int, acc_b real, acc_pb real, acc_nb real, acc_lb real, acc_lpb real, acc_lnb real);
    -- acc_number = 0 => accounts total row
    --acc_b account previous balance
    --acc_pb account balance
    --acc_nb account new balance
    --acc_lb account last year balance
    --acc_lpb account last year previous balance
    --acc_lnb account last year new balance

    CREATE OR REPLACE FUNCTION report_balance(
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
                            periods_to_balance_last_previous TEXT
                            )
    RETURNS setof acc AS $$
    DECLARE
			period_balance acc;
                        total_pb real := 0;
                        total_b real := 0;
                        total_nb real := 0;
                        total_lb  real := 0;
                        total_lpb real := 0;
                        total_lnb real := 0;
                        sum_value real := 0;
			accountRecord record;
                        active_acc boolean;

    BEGIN



		FOR accountRecord IN
					SELECT id,name,number FROM accounts
					WHERE accounts.company_id = company
					AND accounts.is_result_account = is_result_report
					ORDER BY accounts.number
		LOOP


                        active_acc := false;

                        --calculating period balance
                        sum_value := NULL;
			IF (periods_to_balance IS NOT NULL AND LENGTH(periods_to_balance) > 0) THEN
							SELECT SUM(amount)
                                                        INTO sum_value
                                                        FROM (journal_operations as jo
                                                        JOIN  journals as j (journal_id) USING (journal_id) )
							WHERE jo.account_id = accountRecord.id
                                                        AND   j.company_id = company
                                                        AND   j.period_id = ANY (CAST (string_to_array(periods_to_balance, ',') AS int[] ))
							AND   (car IS NULL OR jo.car_id = car)
                                                        AND   (project IS NULL OR jo.project_id = project)
                                                        AND   (unit IS NULL OR jo.unit_id = unit)
                                                        AND   (project IS NULL OR jo.project_id = project)
                                                        AND   ( journal_type IS NULL OR j.journal_type_id = journal_type );

                        END IF;

                        IF sum_value IS NULL THEN
                            sum_value := 0;
                        ELSE
                            active_acc := true;
                        END IF;
                        period_balance.acc_b := sum_value;

                        --calculating period previous balance
                        sum_value := NULL;
			IF (periods_to_balance_previous IS NOT NULL AND LENGTH(periods_to_balance_previous) > 0) THEN
                                                        SELECT SUM(amount)
                                                        INTO sum_value
                                                        FROM (journal_operations as jo
                                                        JOIN  journals as j (journal_id) USING (journal_id) )
							WHERE jo.account_id = accountRecord.id
                                                        AND   j.company_id = company
                                                        AND   j.period_id = ANY (CAST (string_to_array(periods_to_balance_previous, ',') AS int[] ))
							AND   (car IS NULL OR jo.car_id = car)
                                                        AND   (project IS NULL OR jo.project_id = project)
                                                        AND   (unit IS NULL OR jo.unit_id = unit)
                                                        AND   (project IS NULL OR jo.project_id = project)
                                                        AND   ( journal_type IS NULL OR j.journal_type_id = journal_type );
                        END IF;

                        IF sum_value IS NULL THEN
                            sum_value := 0;
                        ELSE
                            active_acc := true;
                        END IF;
                        period_balance.acc_pb := sum_value;


                        --calculating last year period balance
                        sum_value := NULL;
			IF (show_last_year IS TRUE AND periods_to_balance_last IS NOT NULL AND LENGTH(periods_to_balance_last) > 0) THEN
                                                        SELECT SUM(amount)
                                                        INTO sum_value
                                                        FROM (journal_operations as jo
                                                        JOIN  journals as j (journal_id) USING (journal_id) )
							WHERE jo.account_id = accountRecord.id
                                                        AND   j.company_id = company
                                                        AND   j.period_id = ANY (CAST (string_to_array(periods_to_balance_last, ',') AS int[] ))
							AND   (car IS NULL OR jo.car_id = car)
                                                        AND   (project IS NULL OR jo.project_id = project)
                                                        AND   (unit IS NULL OR jo.unit_id = unit)
                                                        AND   (project IS NULL OR jo.project_id = project)
                                                        AND   ( journal_type IS NULL OR j.journal_type_id = journal_type );
                        END IF;
                        IF sum_value IS NULL THEN
                            sum_value := 0;
                        ELSE
                            active_acc := true;
                        END IF;
                        period_balance.acc_lb := sum_value;


                        --calculating last year previous period balance
			sum_value := NULL;
                        IF (show_last_year IS TRUE AND periods_to_balance_last_previous IS NOT NULL AND LENGTH(periods_to_balance_last_previous) > 0) THEN
                                                        SELECT SUM(amount)
                                                        INTO sum_value
                                                        FROM (journal_operations as jo
                                                        JOIN  journals as j (journal_id) USING (journal_id) )
							WHERE jo.account_id = accountRecord.id
                                                        AND   j.company_id = company
                                                        AND   j.period_id = ANY (CAST (string_to_array(periods_to_balance_last_previous, ',') AS int[] ))
							AND   (car IS NULL OR jo.car_id = car)
                                                        AND   (project IS NULL OR jo.project_id = project)
                                                        AND   (unit IS NULL OR jo.unit_id = unit)
                                                        AND   (project IS NULL OR jo.project_id = project)
                                                        AND   ( journal_type IS NULL OR j.journal_type_id = journal_type );
                        END IF;
                        IF sum_value IS NULL THEN
                            sum_value := 0;
                        ELSE
                            active_acc := true;
                        END IF;
                        period_balance.acc_lpb := sum_value;



                        period_balance.acc_nb := period_balance.acc_b + period_balance.acc_pb;
                        period_balance.acc_lnb := period_balance.acc_lb + period_balance.acc_lpb;
                        period_balance.acc_name := accountRecord.name;
                        period_balance.acc_number := accountRecord.number;


                        --incrementing total row
                        total_b    := total_b   + period_balance.acc_b;
                        total_pb   := total_pb  + period_balance.acc_pb;
                        total_lb   := total_lb  + period_balance.acc_lb;
                        total_lpb  := total_lpb + period_balance.acc_lpb;


                        --return only active accounts if specified
                        IF (NOT show_only_active_accounts OR active_acc = TRUE) THEN
                                RETURN NEXT period_balance;
                        END IF;


		END LOOP;


                period_balance.acc_nb   := total_b  + total_pb;
                period_balance.acc_lnb  := total_lb + total_lpb;
                period_balance.acc_b := total_b;
                period_balance.acc_pb   := total_pb  ;
                period_balance.acc_lb  := total_lb;
                period_balance.acc_lpb  := total_lpb ;
                period_balance.acc_name := 'total';
                period_balance.acc_number := 0;



        RETURN NEXT  period_balance;
    END;
    $$ LANGUAGE plpgsql;  