-- PF: UNKNOWN_SCHEMA.sa_conn_set_status
-- proc_id: 176
-- generated_at: 2025-12-29T13:53:28.743Z

create procedure dbo.sa_conn_set_status( 
  in conn_status unsigned integer,
  in log_status_chg char(1) ) 
internal name 'sa_conn_set_status'
