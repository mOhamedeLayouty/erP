-- PF: UNKNOWN_SCHEMA.sa_forward_to
-- proc_id: 157
-- generated_at: 2025-12-29T13:53:28.738Z

create procedure dbo.sa_forward_to( 
  in @server_name char(128) ) 
at 'anyserver...sp_forward_to'
