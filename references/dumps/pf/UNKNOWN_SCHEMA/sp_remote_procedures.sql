-- PF: UNKNOWN_SCHEMA.sp_remote_procedures
-- proc_id: 152
-- generated_at: 2025-12-29T13:53:28.737Z

create procedure dbo.sp_remote_procedures( 
  in @server_name char(128),
  in @sp_name char(128) default '%',
  in @sp_owner char(128) default '%',
  in @sp_qualifier char(128) default '%' ) 
result( 
  database char(128),
  owner char(128),
  proc_name char(128) ) dynamic result sets 1
at 'anyserver...sp_remote_procedures'
