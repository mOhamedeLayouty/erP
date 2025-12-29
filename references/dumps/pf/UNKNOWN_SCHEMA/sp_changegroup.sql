-- PF: UNKNOWN_SCHEMA.sp_changegroup
-- proc_id: 9
-- generated_at: 2025-12-29T13:53:28.693Z

create procedure dbo.sp_changegroup( 
  in @grpname char(128),
  in @name_in_db char(128) ) 
begin
  call dbo.sp_checkperms('DBA');
  execute immediate with quotes on
    'grant membership in group "' || @grpname
     || '" to "' || @name_in_db || '"'
end
