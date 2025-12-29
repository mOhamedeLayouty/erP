-- PF: UNKNOWN_SCHEMA.sa_int_column_stats
-- proc_id: 250
-- generated_at: 2025-12-29T13:53:28.765Z

create procedure dbo.sa_int_column_stats( 
  in table_name char(128),
  in column_name char(128),
  in table_owner char(128),
  in max_rows integer ) 
internal name 'sa_int_column_stats'
