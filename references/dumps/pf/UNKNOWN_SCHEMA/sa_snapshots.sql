-- PF: UNKNOWN_SCHEMA.sa_snapshots
-- proc_id: 237
-- generated_at: 2025-12-29T13:53:28.761Z

create procedure dbo.sa_snapshots()
result( 
  connection_num integer,
  start_sequence_num unsigned bigint,
  statement_level bit ) dynamic result sets 1
internal name 'sa_snapshots'
