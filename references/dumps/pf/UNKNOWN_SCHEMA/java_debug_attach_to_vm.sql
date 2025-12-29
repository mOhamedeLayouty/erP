-- PF: UNKNOWN_SCHEMA.java_debug_attach_to_vm
-- proc_id: 127
-- generated_at: 2025-12-29T13:53:28.729Z

create procedure dbo.java_debug_attach_to_vm( 
  in vm_name char(128),
  out debugger long binary ) 
internal name 'java_debug_attach_to_vm'
