-- PF: UNKNOWN_SCHEMA.sa_text_index_handles
-- proc_id: 244
-- generated_at: 2025-12-29T13:53:28.763Z

create procedure dbo.sa_text_index_handles( 
  in indexname char(128),
  in tabname char(128),
  in tabowner char(128) default null ) 
result( 
  rid unsigned bigint,
  col unsigned integer,
  handle unsigned integer,
  length unsigned integer ) dynamic result sets 1
internal name 'sa_text_index_handles'
