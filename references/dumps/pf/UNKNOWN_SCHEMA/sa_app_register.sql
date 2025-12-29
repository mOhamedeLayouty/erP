-- PF: UNKNOWN_SCHEMA.sa_app_register
-- proc_id: 169
-- generated_at: 2025-12-29T13:53:28.741Z

create procedure dbo.sa_app_register( 
  out cookie unsigned integer,
  in app_name char(255),
  in app_info_str char(255),
  in conn_status unsigned integer,
  in log_status_chg char(1),
  in hold_lock char(1),
  in conn_label char(255) default 'ROOT',
  in exclusive char(1) default 'Y' ) 
internal name 'sa_app_register'
