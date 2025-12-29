-- PF: UNKNOWN_SCHEMA.sp_dropgroup
-- proc_id: 11
-- generated_at: 2025-12-29T13:53:28.694Z

create procedure dbo.sp_dropgroup( 
  in @grpname char(128) ) 
begin
  call dbo.sp_checkperms('DBA');
  execute immediate with quotes on
    'revoke group from "' || @grpname || '"'
end
