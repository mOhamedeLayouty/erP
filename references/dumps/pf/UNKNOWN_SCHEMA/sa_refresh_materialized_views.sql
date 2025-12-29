-- PF: UNKNOWN_SCHEMA.sa_refresh_materialized_views
-- proc_id: 221
-- generated_at: 2025-12-29T13:53:28.756Z

create procedure dbo.sa_refresh_materialized_views( in ignore_errors integer default 0 ) 
begin
  declare errview char(128);
  for lp2 as vc dynamic scroll cursor for
    select u.user_name,table_name
      from SYS.SYSTAB as v join SYS.SYSUSER as u on(v.creator = u.user_id)
        join SYS.SYSOBJECT as o on(o.object_id = v.object_id)
        join SYS.SYSVIEW as m on(v.object_id = m.view_object_id)
      where table_type = 2 and o.status <> 4
      and mv_last_refreshed_at is null
      order by table_id asc
  do
    execute immediate 'refresh materialized view "'
       || user_name || '"."' || table_name || '"'
  end for;
  if ignore_errors = 0 then
    select first u.user_name,table_name
      into errview from SYS.SYSTAB as v join SYS.SYSUSER as u on(v.creator = u.user_id)
        join SYS.SYSOBJECT as o on(o.object_id = v.object_id)
        join SYS.SYSVIEW as m on(v.object_id = m.view_object_id)
      where table_type = 2 and o.status <> 4
      and mv_last_refreshed_at is null;
    if errview is not null then
      raiserror 30001 'Unable to recompile view "' || errview || '"'
    end if
  end if
end
