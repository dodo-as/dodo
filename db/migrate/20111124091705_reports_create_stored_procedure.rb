class ReportsCreateStoredProcedure < ActiveRecord::Migration

  # This is a migration of a basic stored procedure to check the feasibility of stored procedures with Rails
  def self.up

    sql=<<-END_OF_SQL_CODE

    CREATE FUNCTION n_rows_counties(x int, OUT y int) AS $$
    BEGIN
    y = x * 10;
    END;
    $$ LANGUAGE plpgsql;  

    END_OF_SQL_CODE
    execute sql    

  end

  def self.down
    execute 'DROP FUNCTION IF EXISTS stored_proc_test'
  end

end
