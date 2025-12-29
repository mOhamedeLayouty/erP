-- PF: UNKNOWN_SCHEMA.sa_conn_register
-- proc_id: 174
-- generated_at: 2025-12-29T13:53:28.743Z

create procedure dbo.sa_conn_register( 
  in cookie unsigned integer,
  in conn_status unsigned integer,
  in log_status_chg char(1),
  in conn_label char(255) default null ) 
internal name 'sa_conn_register'
