-- PF: UNKNOWN_SCHEMA.sr_drop_message_server_cursors
-- proc_id: 285
-- generated_at: 2025-12-29T13:53:28.775Z

create procedure dbo.sr_drop_message_server_cursors()
begin
  declare c_dbremote_msgs dynamic scroll cursor for
    select su.user_name
      from SYS.SYSTAB as st
        join SYS.SYSUSER as su on st.creator = su.user_id
      where st.table_name = 'dbremote_msgs';
  declare c_externlogins dynamic scroll cursor for
    select su.user_name
      from SYS.SYSEXTERNLOGIN as sel
        join SYS.SYSSERVER as ss on sel.srvid = ss.srvid
        join SYS.SYSUSER as su on sel.user_id = su.user_id
      where ss.srvname = 'dbremote_msgs_server';
  declare c_procedures dynamic scroll cursor for
    select su.user_name,sp.proc_name
      from SYS.SYSPROCEDURE as sp
        join SYS.SYSUSER as su on sp.creator = su.user_id
      where proc_name in( 'sp_dbremote_main','sp_dbremote_control' ) ;
  declare c_functions dynamic scroll cursor for
    select su.user_name,sp.proc_name
      from SYS.SYSPROCEDURE as sp
        join SYS.SYSUSER as su on sp.creator = su.user_id
      where proc_name in( 'sp_dbremote_user_to_dir' ) ;
  declare @c_user varchar(128);
  declare @c_obj varchar(128);
  declare @stmt long varchar;
  open c_dbremote_msgs with hold;
  fetch first c_dbremote_msgs into @c_user;
  while sqlcode = 0 loop
    set @stmt = 'drop table "' || @c_user || '"."dbremote_msgs"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt;
    fetch next c_dbremote_msgs into @c_user
  end loop;
  close c_dbremote_msgs;
  open c_externlogins with hold;
  fetch first c_externlogins into @c_user;
  while sqlcode = 0 loop
    set @stmt = 'drop externlogin "' || @c_user || '" to "dbremote_msgs_server"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt;
    fetch next c_externlogins into @c_user
  end loop;
  close c_externlogins;
  if exists(select 1 from SYS.SYSSERVER where srvname = 'dbremote_msgs_server') then
    drop server dbremote_msgs_server
  end if;
  if exists(select 1 from SYS.SYSWEBSERVICE where service_name = 'dbremote') then
    drop service dbremote
  end if;
  if exists(select 1 from SYS.SYSWEBSERVICE where service_name = 'dbremote/control') then
    drop service "dbremote/control"
  end if;
  open c_procedures with hold;
  fetch first c_procedures into @c_user,@c_obj;
  while sqlcode = 0 loop
    set @stmt = 'drop procedure "' || @c_user || '"."' || @c_obj || '"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt;
    fetch next c_procedures into @c_user,@c_obj
  end loop;
  close c_procedures;
  open c_functions with hold;
  fetch first c_functions into @c_user,@c_obj;
  while sqlcode = 0 loop
    set @stmt = 'drop function "' || @c_user || '"."' || @c_obj || '"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt;
    fetch next c_functions into @c_user,@c_obj
  end loop;
  close c_functions
end
