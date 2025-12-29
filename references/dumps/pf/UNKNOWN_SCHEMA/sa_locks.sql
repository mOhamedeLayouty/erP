-- PF: UNKNOWN_SCHEMA.sa_locks
-- proc_id: 163
-- generated_at: 2025-12-29T13:53:28.740Z

create procedure dbo.sa_locks( 
  in connection integer default 0,
  in creator char(128) default null,
  in table_name char(128) default null,
  in max_locks integer default 1000 ) 
result( 
  conn_name varchar(128),
  conn_id integer,
  user_id varchar(128),
  table_type char(6),
  creator varchar(128),
  table_name varchar(128),
  index_id integer,
  lock_class char(16),
  lock_duration char(12),
  lock_type char(16),
  row_identifier unsigned bigint ) dynamic result sets 1
internal name 'sa_locks'
