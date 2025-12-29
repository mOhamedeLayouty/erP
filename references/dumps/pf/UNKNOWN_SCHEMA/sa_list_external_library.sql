-- PF: UNKNOWN_SCHEMA.sa_list_external_library
-- proc_id: 261
-- generated_at: 2025-12-29T13:53:28.769Z

create procedure dbo.sa_list_external_library()
result( 
  Library_Name long varchar,
  Reference_Count integer ) dynamic result sets 1
begin
  declare local temporary table sa_extlib_list_table(
    Library_Name long varchar null,
    Reference_Count integer null,) in SYSTEM not transactional;
  call dbo.sa_internal_list_external_library();
  select * from sa_extlib_list_table
end
