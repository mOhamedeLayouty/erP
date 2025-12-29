-- PF: UNKNOWN_SCHEMA.sa_sync
-- proc_id: 167
-- generated_at: 2025-12-29T13:53:28.741Z

create procedure dbo.sa_sync( 
  in pub_id integer,
  in operation varchar(128),
  in value varchar(128) ) 
internal name 'sa_sync'
