-- PF: UNKNOWN_SCHEMA.sa_recompile_views
-- proc_id: 218
-- generated_at: 2025-12-29T13:53:28.755Z

create procedure dbo.sa_recompile_views( in ignore_errors integer default 0 ) 
begin
  declare modify_count integer;
  declare was_error integer;
  declare errview char(128);
  lp: loop
    set modify_count = 0;
    for lp2 as vc dynamic scroll cursor for
      select u.user_name,table_name
        from SYS.SYSTAB as t
          join SYS.SYSVIEW as v on(v.view_object_id = t.object_id)
          join SYS.SYSUSER as u on(u.user_id = t.creator)
          join SYS.SYSOBJECT as o on(o.object_id = t.object_id)
        where o.status <> 4
        and not exists(select * from SYS.SYSTABCOL
          where table_id = t.table_id)
        order by table_id asc
    do
      set was_error = 0;
      begin
        execute immediate 'alter view "'
           || user_name || '"."' || table_name || '" recompile'
      exception
        when others then set was_error = 1
      end;
      if was_error = 0 then
        set modify_count = modify_count+1
      end if
    end for;
    if modify_count = 0 then leave lp end if
  end loop lp;
  if ignore_errors = 0 then
    select first table_name
      into errview from SYS.SYSTAB as t
        join SYS.SYSVIEW as v on(v.view_object_id = t.object_id)
      where not exists(select * from SYS.SYSTABCOL
        where table_id = t.table_id);
    if errview is not null then
      raiserror 30000 'Unable to recompile view "' || errview || '"'
    end if
  end if
end
