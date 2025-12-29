-- PF: UNKNOWN_SCHEMA.sp_dropuser
-- proc_id: 15
-- generated_at: 2025-12-29T13:53:28.695Z

create procedure dbo.sp_dropuser( 
  in @name_in_db char(128) ) 
begin
  call dbo.sp_checkperms('DBA');
  execute immediate with quotes on
    'revoke connect from "' || @name_in_db || '"'
end
