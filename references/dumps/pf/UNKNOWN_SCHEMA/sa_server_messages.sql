-- PF: UNKNOWN_SCHEMA.sa_server_messages
-- proc_id: 256
-- generated_at: 2025-12-29T13:53:28.767Z

create procedure dbo.sa_server_messages( 
  in first_msg unsigned bigint default null,
  in num_msgs bigint default null ) 
result( 
  msg_id unsigned bigint,
  msg_text long varchar,
  msg_time timestamp,
  msg_severity varchar(255),
  msg_category varchar(255),
  msg_database varchar(255) ) dynamic result sets 1
internal name 'sa_server_messages'
