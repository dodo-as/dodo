  -- create dagbok journal operations row type for returning
    CREATE TYPE dagbokop AS (jtypeid int,jid int, jnumber int, jdate date, jperiod text,accnumber integer, joamount numeric(20,2), jkid varchar(255), invoice_number varchar(255), jdescription varchar(255) );

    CREATE OR REPLACE FUNCTION report_dagbok(  
                                               company int,  --
                                               from_date date, --
                                               to_date date, --
                                               from_period int, --
                                               to_period int, --
                                               from_account_number int, --
                                               to_account_number int, --
                                               from_journal_number int, --
                                               to_journal_number int, --
                                               filter_by_ledgers boolean,--
                                               ledger_ids TEXT,--
                                               unit int, --
                                               project int, --
                                               car int, --
                                               journal_type int, --
                                               mva_code varchar,
                                               mva_percentage real,
                                               description varchar, --
                                               amount_from real, --
                                               amount_to real, --
                                               kid_from varchar,
                                               kid_to varchar,
                                               invoice_number_from varchar,
                                               invoice_number_to varchar,
                                               sorted_by varchar
                                              )
    RETURNS setof dagbokop AS $$

    DECLARE

           temp record;

           period_from_nr integer;
           period_from_year integer;
           period_to_nr integer;
           period_to_year integer;


    BEGIN

                    IF from_period IS NOT NULL THEN
                        SELECT periods.year,periods.nr INTO period_from_year,period_from_nr from periods where periods.id = from_period;
                    END IF;
                    IF to_period IS NOT NULL THEN
                        SELECT periods.year,periods.nr INTO period_to_year,period_to_nr from periods where periods.id = to_period;
                    END IF;


                     FOR temp IN
                            SELECT  j.journal_type_id AS jtypeid,
                            j.journal_id AS jid,
                            j.number AS jnumber,
                            j.journal_date AS jdate,
                            p.year || ' '  || p.nr AS jperiod ,
                            a.number AS accnumber ,
                            jo.amount AS amount,
                            j.kid AS kid,
                            j.bill_number AS invoice_number,
                            j.description AS jdescription

                            FROM  (journal_operations as jo
                            JOIN  journals AS j (journal_id) USING (journal_id)
                            JOIN  periods AS p (period_id) USING (period_id)
                            JOIN  accounts AS a (account_id) USING (account_id))

                            WHERE j.company_id = company
                            AND ( from_date IS NULL OR j.journal_date >= from_date)
                            AND ( to_date IS NULL OR j.journal_date <= to_date)
                            AND ( from_period IS NULL OR (p.year > period_from_year OR p.year = period_from_year AND p.nr >= period_from_nr))
                            AND ( to_period IS NULL OR   (p.year < period_to_year OR p.year = period_to_year AND p.nr <= period_to_nr) )
                            AND ( from_account_number IS NULL OR a.number >= from_account_number )
                            AND ( to_account_number IS NULL OR a.number <= to_account_number)
                            AND ( from_journal_number IS NULL OR j.number >= from_journal_number)
                            AND ( to_journal_number IS NULL OR j.number <= to_journal_number)
                            AND ( filter_by_ledgers IS FALSE OR (jo.ledger_id IS NULL OR jo.ledger_id = ANY (CAST (string_to_array(ledger_ids, ',') AS int[] ))))
                            AND ( description IS NULL OR j.description LIKE '%'|| description ||'%')
                            AND ( amount_from IS NULL OR jo.amount >= amount_from )
                            AND ( amount_to IS NULL OR jo.amount <= amount_to )
                            AND (car IS NULL OR jo.car_id = car)
                            AND (project IS NULL OR jo.project_id = project)
                            AND (unit IS NULL OR jo.unit_id = unit)
                            AND (journal_type IS NULL OR j.journal_type_id = journal_type)
                            AND jo.amount IS NOT NULL
                            ORDER BY p.year,p.nr,j.journal_date
                            LIMIT 1000
                      LOOP
                        RETURN NEXT temp;
                      END LOOP;

    END;
    $$ LANGUAGE plpgsql;
