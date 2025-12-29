-- PF: UNKNOWN_SCHEMA.sa_get_user_status
-- proc_id: 257
-- generated_at: 2025-12-29T13:53:28.767Z

create procedure dbo.sa_get_user_status()
result( 
  user_id unsigned integer,
  user_name char(128),
  connections integer,
  failed_logins unsigned integer,
  last_login_time timestamp,
  locked tinyint,
  reason_locked long varchar ) dynamic result sets 1
sql security invoker
internal name 'sa_get_user_status'
