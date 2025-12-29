-- PF: UNKNOWN_SCHEMA.sp_columns
-- proc_id: 20
-- generated_at: 2025-12-29T13:53:28.697Z

create procedure dbo.sp_columns( in @table_name char(1024) default '%',
  in @table_owner char(1024) default '%',
  in @table_qualifier char(1024) default '%',
  in @column_name char(1024) default '%' ) 
result( 
  table_qualifier varchar(128),
  table_owner varchar(128),
  table_name varchar(128),
  column_name varchar(128),
  data_type smallint,
  type_name varchar(128),
  "precision" integer,
  length integer,
  scale smallint,
  radix smallint,
  nullable smallint,
  remarks varchar(254),
  ss_data_type smallint,
  colid unsigned integer ) dynamic result sets 1
begin
  select cast(current database as varchar(128)) as table_qualifier,
    cast(u.user_name as varchar(128)) as table_owner,
    cast(table_name as varchar(128)),
    cast(column_name as varchar(128)),
    cast(d.type_id as smallint),
    cast(ifnull(c.user_type,sst.ss_type_name,
    (select type_name from SYS.SYSUSERTYPE
      where type_id = c.user_type)) as varchar(128)) as type_name,
    cast(isnull(d."precision",width) as integer) as "precision",
    cast(width as integer) as length,
    cast(scale as smallint),
    cast((if d.domain_id in( 1,2,3,4,5,19,20,21,22,23,27 ) then
      10
    else
      null
    endif) as smallint) as radix,
    cast((if nulls = 'Y' then 1 else 0 endif) as smallint) as nullable,
    cast(null as varchar(254)) as remarks,
    cast(sst.ss_domain_id as smallint),
    column_id
    from SYS.SYSCOLUMN as c
      ,SYS.SYSTABLE as t
      ,SYS.SYSDOMAIN as d
      ,SYS.SYSTYPEMAP as map
      ,SYS.SYSSQLSERVERTYPE as sst
      ,SYS.SYSUSER as u
    where c.table_id = t.table_id
    and t.table_name like @table_name
    and t.creator = u.user_id
    and u.user_name like @table_owner
    and c.domain_id = d.domain_id
    and map.sa_domain_id = c.domain_id
    and(map.sa_user_type = c.user_type
    or(select count() from SYS.SYSTYPEMAP where sa_user_type = c.user_type) = 0 and(map.sa_user_type is null))
    and sst.ss_user_type = map.ss_user_type
    and(map.nullable is null or map.nullable = 'N')
    and c.column_name like @column_name
    order by u.user_name asc,t.table_name asc,c.column_id asc
end
