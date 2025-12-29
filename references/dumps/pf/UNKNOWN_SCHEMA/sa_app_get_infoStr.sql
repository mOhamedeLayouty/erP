-- PF: UNKNOWN_SCHEMA.sa_app_get_infoStr
-- proc_id: 173
-- generated_at: 2025-12-29T13:53:28.742Z

create procedure dbo.sa_app_get_infoStr( 
  in app_name char(255),
  out app_info_str char(255) ) 
internal name 'sa_app_get_infoStr'
