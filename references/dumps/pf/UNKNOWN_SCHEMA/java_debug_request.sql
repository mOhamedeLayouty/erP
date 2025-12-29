-- PF: UNKNOWN_SCHEMA.java_debug_request
-- proc_id: 129
-- generated_at: 2025-12-29T13:53:28.730Z

create procedure dbo.java_debug_request( 
  in debugger long binary,
  in request long binary,
  out out_request long binary ) 
internal name 'java_debug_request'
