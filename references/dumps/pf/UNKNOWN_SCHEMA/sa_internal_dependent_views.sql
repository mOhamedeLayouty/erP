-- PF: UNKNOWN_SCHEMA.sa_internal_dependent_views
-- proc_id: 79
-- generated_at: 2025-12-29T13:53:28.714Z

create procedure dbo.sa_internal_dependent_views( 
  in table_id unsigned integer,
  in table_obj_id unsigned bigint ) 
internal name 'sa_dependent_views'
