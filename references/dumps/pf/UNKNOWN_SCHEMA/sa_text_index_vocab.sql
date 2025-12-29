-- PF: UNKNOWN_SCHEMA.sa_text_index_vocab
-- proc_id: 241
-- generated_at: 2025-12-29T13:53:28.762Z

create procedure dbo.sa_text_index_vocab( 
  in indexname char(128),
  in tabname char(128),
  in tabowner char(128) default null ) 
result( 
  term varchar(60 char),
  freq bigint ) dynamic result sets 1
internal name 'sa_text_index_vocab'
