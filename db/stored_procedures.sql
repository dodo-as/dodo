    ---- this function generate report for balance or result accounts
    ---- input parameters
        --* periods
        --* filtering options : car, unit, project, journal_type, show_only_active_accounts
        --* is_result_report : determine which part of the report will be generated

    CREATE FUNCTION report(
                            is_result_report boolean ,
                            company_id int ,
                            car_id int,
                            unit_id int,
                            journal_type_id int,
                            show_last_period boolean,
                            show_only_active_accounts boolean,
                            periods_to_balance varchar,
                            periods_to_balance_previous varchar,
                            periods_to_balance_last varchar,
                            periods_to_balance_last_previous varchar )
    RETURNS SETOF RECORD  AS $$
    DECLARE

          --declarations goes here
    BEGIN

    
    --RETURN result;
    END;
    $$ LANGUAGE plpgsql;