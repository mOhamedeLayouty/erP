-- PF: UNKNOWN_SCHEMA.sp_droplogin
-- proc_id: 12
-- generated_at: 2025-12-29T13:53:28.694Z

create procedure dbo.sp_droplogin( 
  in @login_name char(128) ) 
begin
  call dbo.sp_checkperms('DBA');
  execute immediate with quotes on
    'revoke connect from "' || @login_name || '"'
end
