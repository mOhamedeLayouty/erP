-- PF: UNKNOWN_SCHEMA.sa_migrate_get_insert_columns
-- proc_id: 317
-- generated_at: 2025-12-29T13:53:28.785Z

create function dbo.sa_migrate_get_insert_columns( in t_id integer ) 
returns varchar(32000)
begin
  declare col_list varchar(32000);
  declare uuidstr_id smallint;
  select type_id
    into uuidstr_id from SYS.SYSUSERTYPE where type_name = 'uniqueidentifierstr';
  if uuidstr_id is null then set uuidstr_id = -1 end if;
  select list(col,', ' order by col_id asc)
    into col_list
    from(select string(space(10),
        if isnull(sc.user_type,-2) = uuidstr_id then 'strtouuid( ' endif,
        '"',sc.column_name,'"',
        if isnull(sc.user_type,-2) = uuidstr_id then ' )' endif),
        sc.column_id
        from SYS.SYSTABLE as st
          join SYS.SYSCOLUMN as sc on(st.table_id = sc.table_id)
          join SYS.SYSDOMAIN as sd on(sc.domain_id = sd.domain_id)
        where st.table_id = t_id) as collist( col,
      col_id ) ;
  return col_list
end
