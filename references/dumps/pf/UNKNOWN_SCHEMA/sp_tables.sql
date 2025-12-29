-- PF: UNKNOWN_SCHEMA.sp_tables
-- proc_id: 28
-- generated_at: 2025-12-29T13:53:28.699Z

create procedure dbo.sp_tables( 
  in @table_name char(1024) default '%',
  in @table_owner char(1024) default '%',
  in @table_qualifier char(1024) default '%',
  in @table_type char(1024) default '%' ) 
result( 
  table_qualifier varchar(128),
  table_owner varchar(128),
  table_name varchar(128),
  table_type varchar(128),
  remarks varchar(254) ) dynamic result sets 1
begin
  select cast(current database as varchar(128)),
    cast(creator as varchar(128)),
    cast(tname as varchar(128)),
    cast((if tabletype = 'VIEW' then
      'VIEW'
    else
      if creator = 'SYS' and tabletype = 'TABLE' then
        'SYSTEM TABLE'
      else
        'TABLE'
      endif
    endif) as varchar(128)),
    cast(null as varchar(254))
    from SYS.SYSCATALOG
    where(creator like @table_owner)
    and(tname like @table_name)
    and(@table_type = '%'
    or(locate(@table_type,'''TABLE''') <> 0
    and tabletype <> 'VIEW' and creator <> 'SYS')
    or(locate(@table_type,'''VIEW''') <> 0
    and tabletype = 'VIEW')
    or(locate(@table_type,'''SYSTEM TABLE''') <> 0
    and tabletype <> 'VIEW' and creator = 'SYS'))
    and(current database like @table_qualifier)
end
