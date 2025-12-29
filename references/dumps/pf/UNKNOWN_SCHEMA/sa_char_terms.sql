-- PF: UNKNOWN_SCHEMA.sa_char_terms
-- proc_id: 239
-- generated_at: 2025-12-29T13:53:28.762Z

create procedure dbo.sa_char_terms( 
  in text long varchar,
  in config_name char(128) default 'default_char',
  in owner char(128) default null ) 
result( 
  term varchar(60 char),
  position unsigned integer ) dynamic result sets 1
internal name 'sa_char_terms'
