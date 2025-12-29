-- PF: UNKNOWN_SCHEMA.sa_internal_reset_identity
-- proc_id: 93
-- generated_at: 2025-12-29T13:53:28.719Z

create procedure dbo.sa_internal_reset_identity( 
  in tbl_name char(128),
  in owner_name char(128),
  in new_identity bigint ) 
internal name 'sa_reset_identity'
