-- PF: UNKNOWN_SCHEMA.sa_set_http_header
-- proc_id: 213
-- generated_at: 2025-12-29T13:53:28.754Z

create procedure dbo.sa_set_http_header( 
  in fldname char(128),
  in val long varchar ) 
internal name 'sa_set_http_header'
