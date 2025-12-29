-- PF: UNKNOWN_SCHEMA.col_length
-- proc_id: 32
-- generated_at: 2025-12-29T13:53:28.700Z

create function dbo.col_length( 
  in @object_name char(257),
  in @column_name char(128) ) 
returns integer
on exception resume
begin
  declare sz integer;
  declare objid integer;
  set objid = object_id(@object_name);
  select width
    into sz from SYS.SYSTABCOL as c
      join SYS.SYSTAB as t on(t.table_id = c.table_id)
    where t.object_id = objid
    and column_name = @column_name;
  return(sz)
end
