-- PF: UNKNOWN_SCHEMA.sa_migrate_create_fks
-- proc_id: 321
-- generated_at: 2025-12-29T13:53:28.786Z

create procedure dbo.sa_migrate_create_fks( in i_table_owner varchar(128) ) 
begin
  declare stmt long varchar;
  declare pk_col_list long varchar;
  declare fk_col_list long varchar;
  for fk as fkc dynamic scroll cursor for
    select ef.pk_table as o_pk_table,
      ef.pk_name as o_pk_name,
      ef.fk_table as o_fk_table,
      ef.fk_name as o_fk_name
      from dbo.migrate_remote_fks_list as ef,dbo.migrate_remote_table_list as et
      where ef.fk_table = et.table_name
      group by ef.pk_table,ef.pk_name,ef.fk_table,ef.fk_name
  do
    select list(pk_column order by key_seq asc),
      list(fk_column order by key_seq asc)
      into pk_col_list,fk_col_list
      from dbo.migrate_remote_fks_list
      where fk_table = o_fk_table
      and pk_table = o_pk_table
      and fk_name = o_fk_name;
    update dbo.migrate_remote_fks_list
      set created = 1
      where fk_name = o_fk_name;
    set stmt = 'ALTER TABLE '
      +'"'+i_table_owner+'"'+'.'+'"'+o_fk_table+'"'
      +' ADD FOREIGN KEY "'+o_fk_name+'" ( '
      +fk_col_list
      +' ) REFERENCES '
      +'"'+i_table_owner+'"."'+o_pk_table+'" ( '
      +pk_col_list+' )';
    message stmt to client;
    execute immediate stmt
  end for
end
