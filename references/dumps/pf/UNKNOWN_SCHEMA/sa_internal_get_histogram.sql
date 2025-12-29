-- PF: UNKNOWN_SCHEMA.sa_internal_get_histogram
-- proc_id: 81
-- generated_at: 2025-12-29T13:53:28.715Z

create procedure dbo.sa_internal_get_histogram( 
  in col_name char(128),
  in tbl_name char(128),
  in owner_name char(128) ) 
internal name 'sa_get_histogram'
