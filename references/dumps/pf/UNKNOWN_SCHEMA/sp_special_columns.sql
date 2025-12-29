-- PF: UNKNOWN_SCHEMA.sp_special_columns
-- proc_id: 24
-- generated_at: 2025-12-29T13:53:28.698Z

create procedure dbo.sp_special_columns( 
  in @table_name char(128),
  in @table_owner char(128) default null,
  in @table_qualifier char(128) default null,
  in @col_type char(1) default 'R' ) 
result( 
  scope integer,
  column_name char(128),
  data_type smallint,
  type_name char(128),
  "precision" integer,
  length integer,
  scale smallint ) dynamic result sets 1
begin
  declare @indid integer;
  declare @full_table_name long varchar;
  declare objid unsigned bigint;
  declare tabid unsigned integer;
  declare indexid integer;
  if @table_owner is null then
    set @full_table_name = @table_name
  else
    set @full_table_name = @table_owner || '.' || @table_name
  end if;
  set objid = object_id(@full_table_name);
  if objid is null then
    return
  end if;
  select table_id into tabid from SYS.SYSTAB where object_id = objid;
  if @col_type = 'V' then
    select 0,
      column_name,
      d.type_id,
      d.domain_name,
      isnull(d."precision",width),
      width,
      scale
      from SYS.SYSCOLUMN as c,SYS.SYSDOMAIN as d
      where table_id = tabid
      and c.domain_id = d.domain_id
      and("default" = 'autoincrement' or "default" = 'timestamp');
    return
  end if;
  if exists(select * from SYS.SYSCOLUMN
      where table_id = tabid and pkey = 'Y') then
    select 0,
      column_name,
      d.type_id,
      d.domain_name,
      isnull(d."precision",width),
      width,
      scale
      from SYS.SYSCOLUMN as c,SYS.SYSDOMAIN as d
      where table_id = tabid
      and c.domain_id = d.domain_id
      and pkey = 'Y'
      order by column_id asc;
    return
  end if;
  set indexid = (select min(index_id) from SYS.SYSINDEX
      where table_id = tabid and "unique" = 'U');
  if indexid is not null then
    select 0,
      column_name,
      d.type_id,
      d.domain_name,
      isnull(d."precision",width),
      width,
      scale
      from SYS.SYSCOLUMN as c,SYS.SYSDOMAIN as d,SYS.SYSINDEX as ix,SYS.SYSIXCOL as ic
      where c.table_id = tabid
      and c.domain_id = d.domain_id
      and ix.table_id = c.table_id
      and ix.index_id = indexid
      and ic.table_id = ix.table_id
      and ic.index_id = ix.index_id
      order by ic.sequence asc;
    return
  end if
end
