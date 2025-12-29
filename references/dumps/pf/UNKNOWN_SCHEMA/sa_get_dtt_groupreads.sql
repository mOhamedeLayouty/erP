-- PF: UNKNOWN_SCHEMA.sa_get_dtt_groupreads
-- proc_id: 88
-- generated_at: 2025-12-29T13:53:28.716Z

create procedure dbo.sa_get_dtt_groupreads( 
  in dbspace_id unsigned smallint ) 
result( 
  GroupSize unsigned integer,
  ReadTime real ) dynamic result sets 1
internal name 'sa_get_dtt_groupreads'
