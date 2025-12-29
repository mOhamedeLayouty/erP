-- PF: UNKNOWN_SCHEMA.java_debug_get_vm_name
-- proc_id: 125
-- generated_at: 2025-12-29T13:53:28.729Z

create procedure dbo.java_debug_get_vm_name( 
  in vm_handle long binary,
  out vm_name char(128) ) 
internal name 'java_debug_get_vm_name'
