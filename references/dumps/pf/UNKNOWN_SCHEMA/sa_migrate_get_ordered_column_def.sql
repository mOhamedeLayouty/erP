-- PF: UNKNOWN_SCHEMA.sa_migrate_get_ordered_column_def
-- proc_id: 315
-- generated_at: 2025-12-29T13:53:28.784Z

create function dbo.sa_migrate_get_ordered_column_def( in t_id integer ) 
returns varchar(32000)
begin
  declare col_list varchar(32000);
  declare uuidstr_id smallint;
  select type_id
    into uuidstr_id from SYS.SYSUSERTYPE where type_name = 'uniqueidentifierstr';
  if uuidstr_id is null then set uuidstr_id = -1 end if;
  select list(coldef,', ' order by col_id asc)
    into col_list
    from(select string(space(10),
        '"',sc.column_name,'" ',
        if isnull(sc.user_type,-2) = uuidstr_id then 'uniqueidentifier'
        else isnull((select type_name from SYS.SYSUSERTYPE
            where type_id = isnull(sc.user_type,-1)),
          sd.domain_name)
        endif,
        if sd.domain_name in( 'numeric','decimal' ) then
          string('( ',width,', ',scale,' ) ')
        else if sd.domain_name in( 'char','varchar','nchar','nvarchar','binary','varbinary' ) 
          and isnull(sc.user_type,-2) <> uuidstr_id then
            string('( ',width,' ) ')
          endif
        endif,
        if nulls = 'N' then
          ' NOT NULL '
        else
          ' NULL '
        endif,
        if("default" is not null) then
          if(column_type = 'C') then
            ' COMPUTE '+"default"+' '
          else
            ' DEFAULT '+"default"+' '
          endif
        endif),
        sc.column_id
        from SYS.SYSTABLE as st
          join SYS.SYSCOLUMN as sc on(st.table_id = sc.table_id)
          join SYS.SYSDOMAIN as sd on(sc.domain_id = sd.domain_id)
        where st.table_id = t_id) as collist( coldef,
      col_id ) ;
  return col_list
end
