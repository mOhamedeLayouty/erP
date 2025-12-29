-- PF: UNKNOWN_SCHEMA.sa_nchar_terms
-- proc_id: 240
-- generated_at: 2025-12-29T13:53:28.762Z

create procedure dbo.sa_nchar_terms( 
  in text long nvarchar,
  in config_name char(128) default 'default_nchar',
  in owner char(128) default null ) 
result( 
  term nvarchar(60),
  position unsigned integer ) dynamic result sets 1
internal name 'sa_nchar_terms'
