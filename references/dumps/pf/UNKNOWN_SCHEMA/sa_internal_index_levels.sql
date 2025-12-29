-- PF: UNKNOWN_SCHEMA.sa_internal_index_levels
-- proc_id: 77
-- generated_at: 2025-12-29T13:53:28.714Z

create procedure dbo.sa_internal_index_levels( 
  in tbl_name char(128),
  in owner_name char(128) ) 
internal name 'sa_index_levels'
