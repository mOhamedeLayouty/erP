-- PF: UNKNOWN_SCHEMA.sa_internal_materialized_view_info
-- proc_id: 219
-- generated_at: 2025-12-29T13:53:28.756Z

create procedure dbo.sa_internal_materialized_view_info( 
  in view_name char(128),
  in owner_name char(128) ) 
internal name 'sa_materialized_view_info'
