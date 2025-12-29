-- PF: UNKNOWN_SCHEMA.sa_migrate_get_ordered_column_idx
-- proc_id: 318
-- generated_at: 2025-12-29T13:53:28.785Z

create function dbo.sa_migrate_get_ordered_column_idx( in i_name char(128),in t_id integer ) 
returns varchar(32000)
begin
  declare col_list varchar(32000);
  select list(col,', ' order by col_ord asc)
    into col_list
    from(select '"'+c2.column_name+'"'
        +if(x2."order" = 'A') then
          ' ASC '
        else
          ' DESC '
        endif,
        x2."order"
        from SYS.SYSIXCOL as x2
          ,SYS.SYSCOLUMN as c2
          ,SYS.SYSINDEX as i
        where x2.table_id = c2.table_id
        and x2.column_id = c2.column_id
        and x2.index_id = i.index_id
        and c2.table_id = i.table_id
        and x2.table_id = t_id
        and i.index_name = i_name) as collist( col,
      col_ord ) ;
  return col_list
end
