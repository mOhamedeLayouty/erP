-- PF: UNKNOWN_SCHEMA.sa_recommend_indexes
-- proc_id: 205
-- generated_at: 2025-12-29T13:53:28.752Z

create procedure dbo.sa_recommend_indexes( 
  in master_id integer default 0,
  in phase integer default 1,
  in use_clustered integer default 0,
  in keep_existing_indexes integer default 0 ) 
begin
  call dbo.sa_internal_recommend_indexes(master_id,
  phase,
  use_clustered,
  keep_existing_indexes)
end
