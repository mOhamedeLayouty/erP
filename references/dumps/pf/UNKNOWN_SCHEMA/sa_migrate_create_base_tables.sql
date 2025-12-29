-- PF: UNKNOWN_SCHEMA.sa_migrate_create_base_tables
-- proc_id: 314
-- generated_at: 2025-12-29T13:53:28.784Z

create procedure dbo.sa_migrate_create_base_tables( 
  in i_table_owner varchar(128) ) 
begin
  -- Clean up from previous run
  delete from dbo.migrate_sql_defn;
  ------------------
  -- Create tables -
  ------------------
  insert into dbo.migrate_sql_defn( unld_str,et_table_id ) 
    select distinct 'CREATE TABLE '
      -- Strip off the _et from the existing table name
      +'"'+i_table_owner+'"."'
      +stuff(st.table_name,length(st.table_name)-2,3,'')+'" ('
      --Column definitions
      +dbo.sa_migrate_get_ordered_column_def(st.table_id)
      +if exists(select * from SYS.SYSCOLUMN
        where pkey = 'Y' and table_id = st.table_id) then
        ','+space(10)
        +'PRIMARY KEY ('
        +(select
          list(
          if(pkey = 'Y') then
            '"'+column_name+'"'
          endif order by
          column_id asc)
          from SYS.SYSCOLUMN
          where table_id = st.table_id)
        +') '
      endif
      +dbo.sa_migrate_get_unique_constraints(st.table_id)
      +')'
      +if st.file_id <> 0 then
        ' IN '+dbspace_name
      endif
      +if(st.remarks is not null) then
        '; COMMENT ON TABLE '+'"'+i_table_owner
        +'"."'+st.table_name+'" IS '''+st.remarks+''';'
      endif,
      et.table_id
      from SYS.SYSUSERPERM as u
        ,SYS.SYSTABLE as st
        ,SYS.SYSFILE as f
        ,dbo.migrate_remote_table_list as et
      where u.user_id = st.creator
      and u.user_id <> 0
      and st.file_id = f.file_id
      and st.table_name = (et.table_name+'_et')
      and et.created_real = 0
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
      dbspace_name,
      last_page,
      remote_location,
      st.remarks,
      primary_hash_limit,
      et.table_id;
  -------------------
  -- Create Indices -
  -------------------
  insert into dbo.migrate_sql_defn( unld_str ) 
    select distinct 'CREATE '
      +if("unique" = 'Y') then
        'UNIQUE '
      endif
      +'INDEX "'+index_name+'" ON "'
      +i_table_owner+'"."'
      +stuff(t.table_name,length(t.table_name)-2,3,'')
      +'" ( '
      +dbo.sa_migrate_get_ordered_column_idx(index_name,t.table_id)
      +')'
      +if(i.file_id <> 0) then
        ' IN '+dbspace_name
      endif
      +';'
      from SYS.SYSUSERPERM as u
        ,SYS.SYSINDEX as i
        ,SYS.SYSIXCOL as x
        ,SYS.SYSCOLUMN as c
        ,SYS.SYSFILE as f
        ,SYS.SYSTABLE as t
        ,dbo.migrate_remote_table_list as et
      where u.user_id = i.creator
      and i.table_id = x.table_id
      and i.index_id = x.index_id
      and x.table_id = c.table_id
      and x.column_id = c.column_id
      and i.file_id = f.file_id
      and t.table_id = c.table_id
      and t.creator <> 0
      and t.table_name = (et.table_name+'_et')
      and t.existing_obj = 'Y'
      and et.created_real = 0
      and i."unique" <> 'U'
      and not t.table_name = any(select name
        from dbo.EXCLUDEOBJECT
        where type in( 'E','U' ) );
  -- Now that the CREATE TABLE statements have been generated to
  -- create BASE tables instead of existing tables, create them.
  for tl as tlc dynamic scroll cursor for
    select unld_str as stmt,et_table_id as t_id
      from dbo.migrate_sql_defn
      order by id asc
  do
    update dbo.migrate_remote_table_list
      set created_real = 1
      where table_id = t_id;
    message stmt to client;
    execute immediate stmt
  end for
end
