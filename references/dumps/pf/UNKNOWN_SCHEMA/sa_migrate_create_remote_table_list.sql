-- PF: UNKNOWN_SCHEMA.sa_migrate_create_remote_table_list
-- proc_id: 311
-- generated_at: 2025-12-29T13:53:28.783Z

create procedure dbo.sa_migrate_create_remote_table_list( 
  in i_server_name varchar(128),
  in i_table_name varchar(128) default null,
  in i_owner_name varchar(128) default null,
  in i_database_name varchar(128) default null ) 
begin
  -- Cleanup from previous runs
  delete from dbo.migrate_remote_table_list;
  -- Populate a table with a list of all the tables that need to be created
  insert into dbo.migrate_remote_table_list
    ( server_name,database_name,owner_name,table_name,table_type ) 
    select i_server_name,rt.database,rt.owner,rt.table_name,rt.table_type
      from dbo.sp_remote_tables(i_server_name,i_table_name,i_owner_name,i_database_name,1) as rt
      where rt.table_type = 'TABLE'
end
