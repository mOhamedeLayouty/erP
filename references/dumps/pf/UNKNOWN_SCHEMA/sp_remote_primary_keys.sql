-- PF: UNKNOWN_SCHEMA.sp_remote_primary_keys
-- proc_id: 147
-- generated_at: 2025-12-29T13:53:28.736Z

create procedure dbo.sp_remote_primary_keys( 
  in @server_name char(128),
  in @table_name char(128),
  in @table_owner char(128) default '%',
  in @table_qualifier char(128) default '%' ) 
result( 
  database char(128),
  owner char(128),
  table_name char(128),
  column_name char(128),
  key_seq smallint,
  pk_name char(128) ) dynamic result sets 1
at 'anyserver...sp_remote_primary_keys'
