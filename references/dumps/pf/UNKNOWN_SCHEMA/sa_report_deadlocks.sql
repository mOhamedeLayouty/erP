-- PF: UNKNOWN_SCHEMA.sa_report_deadlocks
-- proc_id: 229
-- generated_at: 2025-12-29T13:53:28.759Z

create procedure dbo.sa_report_deadlocks()
result( 
  snapshotId bigint,
  snapshotAt timestamp,
  waiter integer,
  who varchar(128),
  what long varchar,
  object_id unsigned bigint,
  record_id bigint,
  owner integer,
  is_victim bit,
  rollback_operation_count unsigned integer ) dynamic result sets 1
internal name 'sa_report_deadlocks'
