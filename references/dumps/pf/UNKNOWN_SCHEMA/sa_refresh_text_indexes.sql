-- PF: UNKNOWN_SCHEMA.sa_refresh_text_indexes
-- proc_id: 246
-- generated_at: 2025-12-29T13:53:28.763Z

create procedure dbo.sa_refresh_text_indexes()
begin
  for lp1 as c1 dynamic scroll cursor for
    select i.index_name,u.user_name,v.table_name
      from SYS.SYSIDX as i,SYS.SYSTAB as v join SYS.SYSUSER as u on(v.creator = u.user_id)
      where i.table_id = v.table_id
      and index_category = 4
      -- skip immediate refresh indexes
      and(select refresh_type from systextidx where index_id = i.object_id and sequence = 1) <> 3
      order by v.table_id asc
  do
    execute immediate 'refresh text index ' || index_name || ' on "'
       || user_name || '"."' || table_name || '"'
  end for
end
