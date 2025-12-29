-- PF: UNKNOWN_SCHEMA.sp_remote_imported_keys
-- proc_id: 150
-- generated_at: 2025-12-29T13:53:28.736Z

create procedure dbo.sp_remote_imported_keys( 
  in @server_name char(128),
  in @sp_name char(128),
  in @sp_owner char(128) default '%',
  in @sp_qualifier char(128) default '%' ) 
result( 
  pk_database char(128),
  pk_owner char(128),
  pk_table char(128),
  pk_column char(128),
  fk_database char(128),
  fk_owner char(128),
  fk_table char(128),
  fk_column char(128),
  key_seq smallint,
  fk_name char(128),
  pk_name char(128) ) dynamic result sets 1
at 'anyserver...sp_remote_imported_keys'
