-- PF: UNKNOWN_SCHEMA.sp_reset_tsql_environment
-- proc_id: 29
-- generated_at: 2025-12-29T13:53:28.699Z

create procedure dbo.sp_reset_tsql_environment()
begin
  if db_property('IQStore') = 'Off' then
    -- SQL Anywhere datastore
    set temporary option close_on_endtrans = 
  end if;
  set temporary option ansinull = ;
  set temporary option tsql_variables = ;
  set temporary option ansi_blanks = 'OFF';
  set temporary option chained = ;
  set temporary option quoted_identifier = ;
  set temporary option allow_nulls_by_default = ;
  set temporary option on_tsql_error = ;
  set temporary option isolation_level = ;
  set temporary option date_format = ;
  set temporary option timestamp_format = ;
  set temporary option time_format = ;
  set temporary option date_order = ;
  set temporary option escape_character = 
end
