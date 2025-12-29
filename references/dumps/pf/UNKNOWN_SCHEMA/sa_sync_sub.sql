-- PF: UNKNOWN_SCHEMA.sa_sync_sub
-- proc_id: 166
-- generated_at: 2025-12-29T13:53:28.740Z

create procedure dbo.sa_sync_sub( 
  in pub_id integer,
  in site_name varchar(128),
  in operation varchar(128),
  in value varchar(128) ) 
internal name 'sa_sync_sub'
