-- PF: UNKNOWN_SCHEMA.sa_make_object
-- proc_id: 194
-- generated_at: 2025-12-29T13:53:28.748Z

create procedure dbo.sa_make_object( 
  in objtype char(30),
  in objname char(128),
  in owner char(128) default null,
  in tabname char(128) default null ) 
begin
  declare owner_specified bit;
  declare qualified_objname long varchar;
  if owner is null then
    set owner = current user;
    set owner_specified = 0
  else
    set owner_specified = 1
  end if;
  if owner <> current user then
    call dbo.sp_checkperms('DBA')
  else
    call dbo.sp_checkperms('RESOURCE')
  end if;
  set qualified_objname = '"' || owner || '"."' || objname || '"';
  if objtype = 'procedure' or objtype = 'function' then
    if not exists
      (select *
        from SYS.SYSPROCEDURE as p join SYS.SYSUSER as u
          on(p.creator = u.user_id)
        where proc_name = objname and user_name = owner) then
      if owner_specified = 0 and exists
        (select *
          from SYS.SYSPROCEDURE as p
          where proc_name = objname) then
        raiserror 20001 'Ambiguous object name';
        return
      end if;
      execute immediate with quotes on
        'create ' || objtype || ' ' || qualified_objname || '( in p1 int ) '
         || if objtype = 'function' then
          ' returns int begin return(1) end'
        else
          ' begin return end'
        endif
    end if
  elseif objtype = 'view' then
    if not exists
      (select *
        from SYS.SYSTAB as t join SYS.SYSUSER as u
          on(t.creator = u.user_id)
        where table_name = objname and user_name = owner) then
      if owner_specified = 0 and exists
        (select *
          from SYS.SYSTAB as t
          where table_name = objname) then
        raiserror 20001 'Ambiguous object name';
        return
      end if;
      execute immediate with quotes on
        'create view ' || qualified_objname || ' '
         || ' as select 1 as a from SYS.DUMMY'
    end if
  elseif objtype = 'service' then
    if not exists
      (select *
        from SYS.SYSWEBSERVICE
        where service_name = objname) then
      execute immediate with quotes on
        'create service "' || objname || '" type ''HTML'''
    end if
  elseif objtype = 'event' then
    if exists
      (select *
        from SYS.SYSEVENT
        where event_name = objname) then
      execute immediate with quotes on
        'drop event "' || objname || '"'
    end if;
    execute immediate with quotes on
      'create event ' || qualified_objname || ' handler begin end'
  elseif objtype = 'trigger' and tabname is not null then
    if not exists
      (select *
        from SYS.SYSTRIGGER as tr
          join SYS.SYSTAB as t
          on(tr.table_id = t.table_id)
          join SYS.SYSUSER as u
          on(t.creator = u.user_id)
        where trigger_name = objname
        and table_name = tabname
        and user_name = owner) then
      if owner_specified = 0 and exists
        (select *
          from SYS.SYSTRIGGER as tr
            join SYS.SYSTAB as t
            on(tr.table_id = t.table_id)
          where trigger_name = objname
          and table_name = tabname) then
        raiserror 20001 'Ambiguous object name';
        return
      end if;
      execute immediate with quotes on
        'create trigger "' || objname || '" before insert order 100 on '
         || '"' || owner || '"."' || tabname || '" '
         || ' for each row '
         || ' begin return end'
    end if
  else raiserror 20000 'Invalid object type specified'
  end if
end
