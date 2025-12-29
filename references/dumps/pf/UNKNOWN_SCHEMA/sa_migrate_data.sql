-- PF: UNKNOWN_SCHEMA.sa_migrate_data
-- proc_id: 319
-- generated_at: 2025-12-29T13:53:28.786Z

create procedure dbo.sa_migrate_data( in i_table_owner varchar(128) ) 
begin
  -- Clean up from previous run
  delete from dbo.migrate_sql_defn;
  insert into dbo.migrate_sql_defn( unld_str,et_table_id ) 
    select distinct 'INSERT INTO '
      +'"'+i_table_owner+'"."'
      +stuff(st.table_name,length(st.table_name)-2,3,'')
      +'" SELECT '
      +dbo.sa_migrate_get_insert_columns(st.table_id)
      +' FROM '
      +'"'+i_table_owner+'"."'+st.table_name+'";',
      et.table_id
      from SYS.SYSUSERPERM as u
        ,SYS.SYSTABLE as st
        ,dbo.migrate_remote_table_list as et
      where u.user_id = st.creator
      and u.user_id <> 0
      and st.table_name = (et.table_name+'_et')
      and et.created_proxy = 1
      and et.created_real = 1
      and et.data_migrated = 0
      and st.table_type = 'BASE'
      and existing_obj = 'Y'
      and not st.table_name = any(select name
        from dbo.EXCLUDEOBJECT
        where type in( 'E','U' ) )
      group by st.table_id,
      st.table_type,
      user_name,
      st.table_name,
      st.file_id,
      last_page,
      remote_location,
      st.remarks,
      primary_hash_limit,
      et.table_id;
  commit work;
  for tl as tlc dynamic scroll cursor for
    select unld_str as stmt,et_table_id as t_id
      from dbo.migrate_sql_defn order by id asc
  do
    update dbo.migrate_remote_table_list
      set data_migrated = 1
      where table_id = t_id;
    message stmt to client;
    execute immediate stmt;
    commit work
  end for
end
