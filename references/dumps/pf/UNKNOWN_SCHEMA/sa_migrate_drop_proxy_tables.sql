-- PF: UNKNOWN_SCHEMA.sa_migrate_drop_proxy_tables
-- proc_id: 322
-- generated_at: 2025-12-29T13:53:28.786Z

create procedure dbo.sa_migrate_drop_proxy_tables( 
  in i_table_owner varchar(128) ) 
begin
  call dbo.sa_migrate_create_proxy_tables('DROP',i_table_owner)
end
