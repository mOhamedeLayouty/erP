-- PF: UNKNOWN_SCHEMA.sa_set_http_option
-- proc_id: 215
-- generated_at: 2025-12-29T13:53:28.755Z

create procedure dbo.sa_set_http_option( 
  in optname char(128),
  in val long varchar ) 
internal name 'sa_set_http_option'
