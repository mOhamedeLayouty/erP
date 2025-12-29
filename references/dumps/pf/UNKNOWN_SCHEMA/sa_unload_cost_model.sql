-- PF: UNKNOWN_SCHEMA.sa_unload_cost_model
-- proc_id: 85
-- generated_at: 2025-12-29T13:53:28.716Z

create procedure dbo.sa_unload_cost_model( 
  in file_name char(256) ) 
begin
  unload
    select * from SYS.SYSOPTSTAT
      where stat_id = 1 into file
    file_name
end
