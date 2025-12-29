-- PF: UNKNOWN_SCHEMA.sp_tsql_environment
-- proc_id: 30
-- generated_at: 2025-12-29T13:53:28.699Z

create procedure dbo.sp_tsql_environment()
begin
  if db_property('IQStore') = 'Off' then
    -- SQL Anywhere datastore
    set temporary option close_on_endtrans = 'OFF'
  end if;
  set temporary option ansinull = 'OFF';
  set temporary option tsql_variables = 'ON';
  set temporary option ansi_blanks = 'ON';
  set temporary option chained = 'OFF';
  set temporary option quoted_identifier = 'OFF';
  set temporary option allow_nulls_by_default = 'OFF';
  set temporary option on_tsql_error = 'CONTINUE';
  set temporary option isolation_level = '1';
  set temporary option date_format = 'YYYY-MM-DD';
  set temporary option timestamp_format = 'YYYY-MM-DD HH:NN:SS.SSS';
  set temporary option time_format = 'HH:NN:SS.SSS';
  set temporary option date_order = 'MDY';
  set temporary option escape_character = 'OFF'
end
