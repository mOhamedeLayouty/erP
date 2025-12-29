-- PF: UNKNOWN_SCHEMA.sa_app_get_status
-- proc_id: 171
-- generated_at: 2025-12-29T13:53:28.742Z

create procedure dbo.sa_app_get_status( 
  in app_name char(255),
  out all_on unsigned integer,
  out all_off unsigned integer ) 
internal name 'sa_app_get_status'
