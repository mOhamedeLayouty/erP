-- PF: UNKNOWN_SCHEMA.sa_text_index_postings
-- proc_id: 243
-- generated_at: 2025-12-29T13:53:28.763Z

create procedure dbo.sa_text_index_postings( 
  in indexname char(128),
  in tabname char(128),
  in tabowner char(128) default null ) 
result( 
  term varchar(60 char),
  rid unsigned bigint,
  col unsigned integer,
  handle unsigned integer,
  position unsigned integer ) dynamic result sets 1
internal name 'sa_text_index_postings'
