-- PF: UNKNOWN_SCHEMA.sp_addgroup
-- proc_id: 4
-- generated_at: 2025-12-29T13:53:28.691Z

create procedure dbo.sp_addgroup( 
  in @grpname char(128) ) 
begin
  call dbo.sp_checkperms('DBA');
  execute immediate with quotes on
    'grant connect, group to "' || @grpname || '"'
end
