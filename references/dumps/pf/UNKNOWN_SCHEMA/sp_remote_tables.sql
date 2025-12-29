-- PF: UNKNOWN_SCHEMA.sp_remote_tables
-- proc_id: 148
-- generated_at: 2025-12-29T13:53:28.736Z

create procedure dbo.sp_remote_tables( 
  in @server_name char(128),
  in @table_name char(128) default '%',
  in @table_owner char(128) default '%',
  in @table_qualifier char(128) default '%',
  in @with_table_type bit default 0 ) 
result( 
  database char(128),
  owner char(128),
  table_name char(4096),
  table_type char(128) ) dynamic result sets 1
at 'anyserver...sp_remote_tables'
