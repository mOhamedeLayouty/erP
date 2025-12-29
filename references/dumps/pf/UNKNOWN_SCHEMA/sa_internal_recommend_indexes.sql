-- PF: UNKNOWN_SCHEMA.sa_internal_recommend_indexes
-- proc_id: 204
-- generated_at: 2025-12-29T13:53:28.752Z

create procedure dbo.sa_internal_recommend_indexes( 
  in master_id unsigned integer,
  in phase unsigned integer,
  in use_clustered unsigned integer,
  in keep_existing_indexes unsigned integer ) 
internal name sa_recommend_indexes
