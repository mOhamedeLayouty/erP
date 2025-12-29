-- PF: UNKNOWN_SCHEMA.sa_migrate_create_remote_fks_list
-- proc_id: 320
-- generated_at: 2025-12-29T13:53:28.786Z

create procedure dbo.sa_migrate_create_remote_fks_list( 
  in server_name varchar(128) ) 
begin
  -- Cleanup from previous runs
  delete from dbo.migrate_remote_fks_list;
  for tl as tlc dynamic scroll cursor for
    select table_id as t_id,
      database_name as db_name,
      owner_name as o_name,
      table_name as t_name
      from dbo.migrate_remote_table_list
      order by table_id asc
  do
    insert into dbo.migrate_remote_fks_list
      ( pk_database,pk_owner,pk_table,pk_column,fk_database,
      fk_owner,fk_table,fk_column,key_seq,fk_name,pk_name ) 
      select ik.pk_database,ik.pk_owner,ik.pk_table,ik.pk_column,ik.fk_database,
        ik.fk_owner,ik.fk_table,ik.fk_column,ik.key_seq,ik.fk_name,ik.pk_name
        from dbo.sp_remote_imported_keys(server_name,t_name,o_name,db_name) as ik
  end for
end
