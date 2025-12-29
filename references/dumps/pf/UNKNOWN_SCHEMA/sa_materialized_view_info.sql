-- PF: UNKNOWN_SCHEMA.sa_materialized_view_info
-- proc_id: 220
-- generated_at: 2025-12-29T13:53:28.756Z

create procedure dbo.sa_materialized_view_info( 
  in view_name char(128) default null,
  in owner_name char(128) default null ) 
result( 
  OwnerName char(128),
  ViewName char(128),
  Status char(1),
  DataStatus char(1),
  ViewLastRefreshed timestamp,
  DataLastModified timestamp,
  AvailForOptimization char(1),
  RefreshType char(1) ) dynamic result sets 1
begin
  declare vname char(128);
  declare uname char(128);
  declare views dynamic scroll cursor for
    select rtrim(table_name),rtrim(user_name)
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_type = 2
      and t.creator = u.user_id
      and(owner_name is null or owner_name = user_name)
      order by t.creator asc,table_name asc;
  declare first_owner dynamic scroll cursor for
    select rtrim(user_name)
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_name = view_name
      and t.creator = u.user_id;
  declare local temporary table MatViewInfo(
    OwnerName char(128) not null,
    TableName char(128) not null,
    Status char(1) not null,
    DataStatus char(1) not null,
    ViewLastRefreshed timestamp null,
    DataLastModified timestamp null,
    AvailForOptimization char(1) not null,
    RefreshType char(1) not null,
    ) in SYSTEM not transactional;
  if view_name is null then
    open views;
    tabs: loop
      fetch next views into vname,uname;
      if sqlcode <> 0 then leave tabs end if;
      call dbo.sa_internal_materialized_view_info(vname,uname);
      if sqlcode <> 0 then leave tabs end if
    end loop tabs;
    close views
  else
    set vname = rtrim(view_name);
    if owner_name is null then
      set uname = '';
      open first_owner;
      fetch next first_owner into uname;
      close first_owner
    else
      set uname = rtrim(owner_name)
    end if;
    call dbo.sa_internal_materialized_view_info(vname,uname)
  end if;
  select * from MatViewInfo
    order by OwnerName asc,TableName asc
end
