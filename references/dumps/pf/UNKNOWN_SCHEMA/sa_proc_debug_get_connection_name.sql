-- PF: UNKNOWN_SCHEMA.sa_proc_debug_get_connection_name
-- proc_id: 134
-- generated_at: 2025-12-29T13:53:28.731Z

create procedure dbo.sa_proc_debug_get_connection_name( 
  in conn_handle long binary,
  out conn_name long varchar ) 
internal name 'sa_proc_debug_get_connection_name'
