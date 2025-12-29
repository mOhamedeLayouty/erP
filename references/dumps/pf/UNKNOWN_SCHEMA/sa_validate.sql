-- PF: UNKNOWN_SCHEMA.sa_validate
-- proc_id: 70
-- generated_at: 2025-12-29T13:53:28.712Z

create procedure dbo.sa_validate( 
  in tbl_name char(128) default null,
  in owner_name char(128) default null,
  in check_type char(10) default null ) 
result( Messages char(128) ) dynamic result sets 1
on exception resume
begin
  declare tname char(128);
  declare uname char(128);
  declare qualified_name char(250);
  declare msg_buf char(250);
  declare counter integer;
  declare tables dynamic scroll cursor for
    select rtrim(table_name),rtrim(user_name)
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_type in( 1,2 ) 
      and server_type = 1
      and t.creator = u.user_id
      order by t.creator asc,table_name asc;
  declare first_owner dynamic scroll cursor for
    select user_name
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_name = tbl_name
      and t.creator = u.user_id;
  declare local temporary table result_msgs(
    rownum integer null,
    Messages char(250) null,) in SYSTEM on commit preserve rows;
  set counter = 0;
  if tbl_name is null then
    execute immediate 'validate database';
    set msg_buf = errormsg();
    if length(msg_buf) > 0 then
      set counter = counter+1;
      insert into result_msgs values( counter,msg_buf ) 
    end if;
    open tables;
    tabs: loop
      fetch next tables into tname,uname;
      if sqlcode <> 0 then leave tabs end if;
      set qualified_name = '"' || uname || '"."' || tname || '"';
      execute immediate with quotes on 'validate table ' || qualified_name;
      set msg_buf = errormsg();
      if length(msg_buf) > 0 then
        set counter = counter+1;
        insert into result_msgs values( counter,msg_buf ) 
      end if
    end loop tabs;
    close tables
  else
    set tname = rtrim(tbl_name);
    if owner_name is null then
      set uname = '';
      open first_owner;
      fetch next first_owner into uname;
      if sqlcode = 0 then
        set uname = '"' || rtrim(uname) || '".'
      end if;
      close first_owner
    else
      set uname = '"' || rtrim(owner_name) || '".'
    end if;
    set qualified_name = uname || '"' || tname || '"';
    execute immediate with quotes on 'validate table ' || qualified_name;
    set msg_buf = errormsg();
    if length(msg_buf) > 0 then
      set counter = counter+1;
      insert into result_msgs values( counter,msg_buf ) 
    end if
  end if;
  if counter = 0 then
    insert into result_msgs values( 1,lang_message(-1) ) 
  end if;
  select Messages from result_msgs order by rownum asc
end
