-- PF: UNKNOWN_SCHEMA.sa_get_histogram
-- proc_id: 82
-- generated_at: 2025-12-29T13:53:28.715Z

create procedure dbo.sa_get_histogram( 
  in col_name char(128),
  in tbl_name char(128),
  in owner_name char(128) default null ) 
result( 
  StepNumber smallint,
  Low char(128),
  High char(128),
  Frequency double ) dynamic result sets 1
begin
  declare cname char(128);
  declare tname char(128);
  declare uname char(128);
  declare first_owner dynamic scroll cursor for
    select rtrim(user_name)
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_name = tbl_name
      and t.creator = u.user_id;
  declare local temporary table HistogramTable(
    StepNo smallint null,
    Low char(128) null,
    High char(128) null,
    Frequency double null,
    ) in SYSTEM not transactional;
  set cname = rtrim(col_name);
  set tname = rtrim(tbl_name);
  if owner_name is null then
    set uname = '';
    open first_owner;
    fetch next first_owner into uname;
    close first_owner
  else
    set uname = rtrim(owner_name)
  end if;
  call dbo.sa_internal_get_histogram(cname,tname,uname);
  select * from HistogramTable order by StepNo asc
end
