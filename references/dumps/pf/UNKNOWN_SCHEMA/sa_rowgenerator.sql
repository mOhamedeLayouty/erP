-- PF: UNKNOWN_SCHEMA.sa_rowgenerator
-- proc_id: 224
-- generated_at: 2025-12-29T13:53:28.757Z

create procedure dbo.sa_rowgenerator( 
  in rstart integer default 0,
  in rend integer default 100,
  in rstep integer default 1 ) 
result( row_num integer ) dynamic result sets 1
internal name 'sa_rowgenerator'
