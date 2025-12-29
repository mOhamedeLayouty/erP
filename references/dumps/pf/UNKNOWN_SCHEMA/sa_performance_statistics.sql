-- PF: UNKNOWN_SCHEMA.sa_performance_statistics
-- proc_id: 253
-- generated_at: 2025-12-29T13:53:28.766Z

create procedure dbo.sa_performance_statistics()
result( 
  DBNumber integer,
  ConnNumber integer,
  PropNum integer,
  PropName varchar(255),
  Value integer ) dynamic result sets 1
internal name 'sa_performance_statistics'
