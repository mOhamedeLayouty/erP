-- PF: UNKNOWN_SCHEMA.sp_remote_columns
-- proc_id: 146
-- generated_at: 2025-12-29T13:53:28.735Z

create procedure dbo.sp_remote_columns( 
  in @server_name char(128),
  in @table_name char(128),
  in @table_owner char(128) default '%',
  in @table_qualifier char(128) default '%' ) 
result( 
  database char(128),
  owner char(128),
  table_name char(128),
  column_name char(128),
  domain_id smallint,
  width integer,
  scale smallint,
  nullable smallint,
  base_type_str char(4096) ) dynamic result sets 1
at 'anyserver...sp_remote_columns'
