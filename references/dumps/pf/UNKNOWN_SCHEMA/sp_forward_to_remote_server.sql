-- PF: UNKNOWN_SCHEMA.sp_forward_to_remote_server
-- proc_id: 158
-- generated_at: 2025-12-29T13:53:28.738Z

create procedure dbo.sp_forward_to_remote_server( 
  in @server_name char(128),
  in @sql long varchar ) 
result( dummy integer ) dynamic result sets 1
at 'anyserver...sp_extended_forward_to'
