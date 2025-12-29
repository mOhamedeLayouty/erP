-- PF: UNKNOWN_SCHEMA.sa_transactions
-- proc_id: 238
-- generated_at: 2025-12-29T13:53:28.761Z

create procedure dbo.sa_transactions()
result( 
  connection_num integer,
  transaction_id integer,
  start_time timestamp,
  start_sequence_num unsigned bigint,
  end_sequence_num unsigned bigint,
  committed bit,
  version_entries unsigned integer ) dynamic result sets 1
internal name 'sa_transactions'
