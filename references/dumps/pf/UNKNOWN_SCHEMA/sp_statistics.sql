-- PF: UNKNOWN_SCHEMA.sp_statistics
-- proc_id: 26
-- generated_at: 2025-12-29T13:53:28.698Z

create procedure dbo.sp_statistics( 
  in @table_name char(1024) default '%',
  in @table_owner char(1024) default '%',
  in @table_qualifier char(1024) default '%',
  in @index_name char(1024) default '%',
  in @is_unique char(1) default 'N' ) 
result( 
  table_qualifier varchar(128),
  table_owner varchar(128),
  table_name varchar(128),
  non_unique smallint,
  index_qualifier varchar(128),
  index_name varchar(128),
  type smallint,
  seq_in_index smallint,
  column_name varchar(128),
  collation char(1),
  cardinality integer,
  pages integer ) dynamic result sets 1
begin
  declare @full_table_name long varchar;
  if @table_owner = '%' then
    set @full_table_name = @table_name
  else
    set @full_table_name = @table_owner || '.' || @table_name
  end if;
  select convert(varchar(128),db_name()) as table_qualifier,
    convert(varchar(128),user_name(tab.creator)) as table_owner,
    convert(varchar(128),tab.table_name) as table_name,
    convert(smallint,null) as non_unique,
    convert(varchar(128),null) as index_qualifier,
    convert(varchar(128),null) as index_name,
    convert(smallint,0) as type,
    convert(smallint,0) as seq_in_index,
    convert(varchar(128),null) as column_name,
    convert(char(1),null) as collation,
    convert(integer,tab.count) as cardinality,
    convert(integer,tab.count) as pages
    from SYS.SYSTAB as tab
    where tab.object_id = object_id(@full_table_name) union all
  select convert(varchar(128),db_name()) as table_qualifier,
    convert(varchar(128),user_name(tab.creator)) as table_owner,
    convert(varchar(128),tab.table_name) as table_name,
    convert(smallint,if "unique" = 'Y' then 0 else 1 endif) as non_unique,
    convert(varchar(128),tab.table_name) as index_qualifier,
    convert(varchar(128),ind.index_name) as index_name,
    convert(smallint,3) as type,
    convert(unsigned integer,ixcol.sequence) as seq_in_index,
    convert(varchar(128),col.column_name) as column_name,
    convert(char(1),ixcol."order") as collation,
    convert(integer,tab.count) as cardinality,
    convert(integer,tab.count) as pages
    from SYS.SYSTAB as tab,SYS.SYSINDEX as ind,SYS.SYSIXCOL as ixcol
      ,SYS.SYSCOLUMN as col
    where tab.object_id = object_id(@full_table_name)
    and ind.table_id = tab.table_id
    and ixcol.index_id = ind.index_id
    and ixcol.table_id = ind.table_id
    and col.table_id = ind.table_id
    and col.column_id = ixcol.column_id
    and ind."unique" <> 'U'
    and ind.index_name like @index_name
    and(@is_unique = 'Y' or ind."unique" = 'N')
    order by 4 asc,7 asc,6 asc,8 asc
end
