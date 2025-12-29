-- PF: UNKNOWN_SCHEMA.sa_proc_debug_attach_to_connection
-- proc_id: 136
-- generated_at: 2025-12-29T13:53:28.732Z

create procedure dbo.sa_proc_debug_attach_to_connection( 
  in connection_handle long binary,
  out debugger long binary ) 
internal name 'sa_proc_debug_attach_to_connection'
