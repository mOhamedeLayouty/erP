-- PF: UNKNOWN_SCHEMA.sp_droptype
-- proc_id: 14
-- generated_at: 2025-12-29T13:53:28.695Z

create procedure dbo.sp_droptype( 
  in @typename char(128) ) 
begin
  call dbo.sp_checkperms('RESOURCE');
  execute immediate with quotes on
    'drop domain "' || @typename || '"'
end
