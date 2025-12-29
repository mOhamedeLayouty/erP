-- PF: UNKNOWN_SCHEMA.xp_real_read_file
-- proc_id: 56
-- generated_at: 2025-12-29T13:53:28.707Z

create procedure dbo.xp_real_read_file( in filename long varchar,out contents long binary,in lazy integer ) 
internal name 'xp_real_read_file'
