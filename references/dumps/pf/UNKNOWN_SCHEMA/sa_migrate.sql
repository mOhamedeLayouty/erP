-- PF: UNKNOWN_SCHEMA.sa_migrate
-- proc_id: 323
-- generated_at: 2025-12-29T13:53:28.787Z

create procedure dbo.sa_migrate( 
  in base_table_owner varchar(128),
  in server_name varchar(128),
  in table_name varchar(128) default null,
  in owner_name varchar(128) default null,
  in database_name varchar(128) default null,
  in migrate_data bit default 1,
  in drop_proxy_tables bit default 1,
  in migrate_fkeys bit default 1 ) 
begin
  call dbo.sa_migrate_create_remote_table_list(
  server_name,table_name,owner_name,database_name);
  call dbo.sa_migrate_create_tables(base_table_owner);
  if(migrate_data = 1) then
    call dbo.sa_migrate_data(base_table_owner)
  end if;
  if(migrate_fkeys = 1) then
    call dbo.sa_migrate_create_remote_fks_list(server_name);
    call dbo.sa_migrate_create_fks(base_table_owner)
  end if;
  if(drop_proxy_tables = 1) then
    call dbo.sa_migrate_create_proxy_tables('DROP',base_table_owner)
  end if
end
