-- PF: UNKNOWN_SCHEMA.sa_index_density
-- proc_id: 90
-- generated_at: 2025-12-29T13:53:28.717Z

create procedure dbo.sa_index_density( 
  in tbl_name char(128) default null,
  in owner_name char(128) default null ) 
result( 
  TableName char(128),
  TableId unsigned integer,
  IndexName char(128),
  IndexId unsigned integer,
  IndexType char(4),
  LeafPages unsigned integer,
  Density double,
  Skew double ) dynamic result sets 1
begin
  declare tname char(128);
  declare uname char(128);
  declare tables dynamic scroll cursor for
    select rtrim(table_name),rtrim(user_name)
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_type = 1
      and t.creator = u.user_id
      and(owner_name is null or owner_name = user_name)
      order by t.creator asc,table_name asc;
  declare first_owner dynamic scroll cursor for
    select rtrim(user_name)
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_name = tbl_name
      and t.creator = u.user_id;
  declare local temporary table IndexDensity(
    TableName char(128) null,
    TableId unsigned integer null,
    IndexName char(128) null,
    IndexId unsigned integer null,
    IndexType char(4) null,
    LeafPages unsigned integer null,
    Density double null,
    Skew double null,
    ) in SYSTEM not transactional;
  if tbl_name is null then
    open tables;
    tabs: loop
      fetch next tables into tname,uname;
      if sqlcode <> 0 then leave tabs end if;
      call dbo.sa_internal_index_density(tname,uname);
      if sqlcode <> 0 then leave tabs end if
    end loop tabs;
    close tables
  else
    set tname = rtrim(tbl_name);
    if owner_name is null then
      set uname = '';
      open first_owner;
      fetch next first_owner into uname;
      close first_owner
    else
      set uname = rtrim(owner_name)
    end if;
    call dbo.sa_internal_index_density(tname,uname)
  end if;
  select * from IndexDensity order by TableName asc,IndexName asc
end
