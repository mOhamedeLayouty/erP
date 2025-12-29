-- PF: UNKNOWN_SCHEMA.sa_ansi_standard_packages
-- proc_id: 235
-- generated_at: 2025-12-29T13:53:28.760Z

create procedure dbo.sa_ansi_standard_packages( in standard long varchar,in statement long varchar ) 
result( package_id varchar(10),package_name long varchar ) dynamic result sets 1
internal name 'sa_ansi_standard_packages'
