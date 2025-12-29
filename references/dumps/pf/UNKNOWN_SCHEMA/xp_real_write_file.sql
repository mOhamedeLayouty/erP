-- PF: UNKNOWN_SCHEMA.xp_real_write_file
-- proc_id: 54
-- generated_at: 2025-12-29T13:53:28.706Z

create function dbo.xp_real_write_file( 
  in filename long varchar,
  in file_contents long binary ) 
returns integer
internal name 'xp_real_write_file'
