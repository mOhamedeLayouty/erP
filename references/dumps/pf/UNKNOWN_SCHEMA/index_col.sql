-- PF: UNKNOWN_SCHEMA.index_col
-- proc_id: 34
-- generated_at: 2025-12-29T13:53:28.701Z

create function dbo.index_col( 
  in @object_name char(128),
  in @index_id integer,
  in @key_# integer,
  in @user_id integer default null ) 
returns char(128)
on exception resume
begin
  declare cname char(128);
  declare objid integer;
  set objid = object_id(@object_name);
  if objid is null then
    return(null)
  end if;
  select column_name
    into cname from SYS.SYSTABCOL as c
      join SYS.SYSTAB as t on(t.table_id = c.table_id)
      join SYS.SYSIXCOL as ixc on(c.table_id = ixc.table_id
      and c.column_id = ixc.column_id)
    where t.object_id = objid
    and index_id = @index_id
    and sequence = @key_#;
  return(cname)
end
