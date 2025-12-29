-- PF: UNKNOWN_SCHEMA.sp_pkeys
-- proc_id: 22
-- generated_at: 2025-12-29T13:53:28.697Z

create procedure dbo.sp_pkeys( 
  in @table_name char(1024),
  in @table_owner char(1024) default null,
  in @table_qualifier char(1024) default null ) 
result( 
  table_qualifier char(128),
  table_owner char(128),
  table_name char(128),
  column_name char(128),
  key_seq unsigned integer ) dynamic result sets 1
begin
  if @table_owner is null then
    set @table_owner = '%'
  end if;
  select current database,
    user_name,
    table_name,
    column_name,
    column_id
    from SYS.SYSTAB as t,SYS.SYSCOLUMN as c,SYS.SYSUSER as u
    where t.table_id = c.table_id
    and t.creator = u.user_id
    and table_name like @table_name
    and user_name like @table_owner
    and pkey in( 'Y','M' ) 
    order by table_name asc,user_name asc,column_id asc
end
