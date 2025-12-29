-- PF: UNKNOWN_SCHEMA.sa_report_blocking
-- proc_id: 231
-- generated_at: 2025-12-29T13:53:28.759Z

create procedure dbo.sa_report_blocking()
result( 
  waiter unsigned integer,
  owner unsigned integer,
  object_id unsigned bigint,
  record_id bigint ) dynamic result sets 1
internal name 'sa_report_blocking'
