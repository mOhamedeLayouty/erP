-- PF: UNKNOWN_SCHEMA.sa_proc_debug_request
-- proc_id: 137
-- generated_at: 2025-12-29T13:53:28.733Z

create procedure dbo.sa_proc_debug_request( 
  in debugger long binary,
  in request long binary,
  out out_request long binary ) 
internal name 'sa_proc_debug_request'
