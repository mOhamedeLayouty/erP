-- PF: UNKNOWN_SCHEMA.sa_internal_materialized_view_can_be_immediate
-- proc_id: 222
-- generated_at: 2025-12-29T13:53:28.757Z

create procedure dbo.sa_internal_materialized_view_can_be_immediate( 
  in view_name char(128),
  in owner_name char(128) ) 
internal name 'sa_materialized_view_can_be_immediate'
