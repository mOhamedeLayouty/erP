-- PF: UNKNOWN_SCHEMA.sp_login_environment
-- proc_id: 31
-- generated_at: 2025-12-29T13:53:28.700Z

create procedure dbo.sp_login_environment()
begin
  if connection_property('CommProtocol') = 'TDS' then
    call dbo.sp_tsql_environment()
  end if
end
