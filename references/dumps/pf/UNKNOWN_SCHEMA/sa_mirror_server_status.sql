-- PF: UNKNOWN_SCHEMA.sa_mirror_server_status
-- proc_id: 266
-- generated_at: 2025-12-29T13:53:28.770Z

create procedure dbo.sa_mirror_server_status()
result( 
  server_name char(128),
  state char(20),
  last_updated timestamp with time zone,
  load_current double,
  load_last_1_min double,
  load_last_5_mins double,
  load_last_10_mins double,
  num_connections unsigned integer,
  num_processors unsigned integer,
  log_written unsigned bigint,
  log_applied unsigned bigint ) dynamic result sets 1
internal name 'sa_mirror_server_status'
