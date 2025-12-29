-- PF: UNKNOWN_SCHEMA.sa_text_index_vocab_nchar
-- proc_id: 242
-- generated_at: 2025-12-29T13:53:28.762Z

create procedure dbo.sa_text_index_vocab_nchar( 
  in indexname char(128),
  in tabname char(128),
  in tabowner char(128) default null ) 
result( 
  term nvarchar(60),
  freq bigint ) dynamic result sets 1
internal name 'sa_text_index_vocab_nchar'
