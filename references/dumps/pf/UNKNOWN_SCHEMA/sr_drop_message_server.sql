-- PF: UNKNOWN_SCHEMA.sr_drop_message_server
-- proc_id: 284
-- generated_at: 2025-12-29T13:53:28.775Z

create procedure dbo.sr_drop_message_server()
begin
  declare @stmt long varchar;
  for l_dbremote_msgs as c_dbremote_msgs dynamic scroll cursor for
    select su.user_name
      from SYS.SYSTAB as st
        join SYS.SYSUSER as su on st.creator = su.user_id
      where st.table_name = 'dbremote_msgs'
  do
    set @stmt = 'drop table "' || user_name || '"."dbremote_msgs"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end for;
  for l_externlogins as c_externlogins dynamic scroll cursor for
    select su.user_name
      from SYS.SYSEXTERNLOGIN as sel
        join SYS.SYSSERVER as ss on sel.srvid = ss.srvid
        join SYS.SYSUSER as su on sel.user_id = su.user_id
      where ss.srvname = 'dbremote_msgs_server'
  do
    set @stmt = 'drop externlogin "' || user_name || '" to "dbremote_msgs_server"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end for;
  if exists(select 1 from SYS.SYSSERVER where srvname = 'dbremote_msgs_server') then
    set @stmt = 'drop server "dbremote_msgs_server"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end if;
  if exists(select 1 from SYS.SYSWEBSERVICE where service_name = 'dbremote') then
    set @stmt = 'drop service "dbremote"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end if;
  if exists(select 1 from SYS.SYSWEBSERVICE where service_name = 'dbremote/control') then
    set @stmt = 'drop service "dbremote/control"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end if;
  for l_procedures as c_procedures dynamic scroll cursor for
    select su.user_name,sp.proc_name
      from SYS.SYSPROCEDURE as sp
        join SYS.SYSUSER as su on sp.creator = su.user_id
      where proc_name in( 'sp_dbremote_main','sp_dbremote_control' ) 
  do
    set @stmt = 'drop procedure "' || user_name || '"."' || proc_name || '"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end for;
  for l_functions as c_functions dynamic scroll cursor for
    select su.user_name,sp.proc_name
      from SYS.SYSPROCEDURE as sp
        join SYS.SYSUSER as su on sp.creator = su.user_id
      where proc_name in( 'sp_dbremote_user_to_dir' ) 
  do
    set @stmt = 'drop function "' || user_name || '"."' || proc_name || '"';
    message 'DBG_SRDMS: ' || @stmt to console debug only;
    execute immediate @stmt
  end for
end
