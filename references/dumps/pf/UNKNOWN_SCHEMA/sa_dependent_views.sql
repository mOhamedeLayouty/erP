-- PF: UNKNOWN_SCHEMA.sa_dependent_views
-- proc_id: 80
-- generated_at: 2025-12-29T13:53:28.714Z

create procedure dbo.sa_dependent_views( 
  in tbl_name char(128) default null,
  in owner_name char(128) default null ) 
result( 
  table_id unsigned integer,
  dep_view_id unsigned integer ) dynamic result sets 1
begin
  declare tid unsigned integer;
  declare oid unsigned bigint;
  declare tables dynamic scroll cursor for
    select t.table_id,t.object_id
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where t.creator = u.user_id
      and(owner_name is null or owner_name = user_name)
      order by t.creator asc,table_name asc;
  declare first_table dynamic scroll cursor for
    select t.table_id,t.object_id
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_name = tbl_name
      and(owner_name is null or owner_name = user_name)
      and t.creator = u.user_id;
  declare local temporary table DependentViewsTable(
    table_id unsigned integer not null,
    dep_view_id unsigned integer not null,
    primary key(table_id,dep_view_id),
    ) in SYSTEM not transactional;
  if tbl_name is null then
    open tables;
    tabs: loop
      fetch next tables into tid,oid;
      if sqlcode <> 0 then leave tabs end if;
      call dbo.sa_internal_dependent_views(tid,oid);
      if sqlcode <> 0 then leave tabs end if
    end loop tabs;
    close tables
  else
    open first_table;
    fetch next first_table into tid,oid;
    close first_table;
    call dbo.sa_internal_dependent_views(tid,oid)
  end if;
  select * from DependentViewsTable order by table_id asc,dep_view_id asc
end
