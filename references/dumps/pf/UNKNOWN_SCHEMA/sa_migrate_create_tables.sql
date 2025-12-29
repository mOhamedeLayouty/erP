-- PF: UNKNOWN_SCHEMA.sa_migrate_create_tables
-- proc_id: 312
-- generated_at: 2025-12-29T13:53:28.783Z

create procedure dbo.sa_migrate_create_tables( in i_table_owner varchar(128) ) 
begin
  -- Now create existing copies of the tables
  -- This allows OMNI to convert the datatypes into ASA
  -- datatypes for us.  After this is done, the ASA
  -- system tables contain all the information necessary
  -- to create permanant base tables
  call dbo.sa_migrate_create_proxy_tables('CREATE',i_table_owner);
  -- Each of the tables have been created with a '_et'
  -- extension.  Now we run a routine that will essentially
  -- unload the table definition and re-create it using
  -- the actual table name, that is a permanent table
  -- instead of a proxy table
  call dbo.sa_migrate_create_base_tables(i_table_owner)
end
