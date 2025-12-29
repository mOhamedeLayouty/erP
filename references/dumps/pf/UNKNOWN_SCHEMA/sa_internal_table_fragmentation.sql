-- PF: UNKNOWN_SCHEMA.sa_internal_table_fragmentation
-- proc_id: 91
-- generated_at: 2025-12-29T13:53:28.718Z

create procedure dbo.sa_internal_table_fragmentation( 
  in tbl_name char(128),
  in owner_name char(128) ) 
internal name 'sa_table_fragmentation'
