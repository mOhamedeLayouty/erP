-- PF: UNKNOWN_SCHEMA.col_name
-- proc_id: 33
-- generated_at: 2025-12-29T13:53:28.701Z

create function dbo.col_name( 
  in @object_id integer,
  in @column_id integer,
  in @database_id integer default null ) 
returns char(128)
on exception resume
begin
  declare cname char(128);
  select name
    into cname from dbo.syscolumns
    where id = @object_id
    and colid = @column_id;
  if sqlcode <> 0 then
    return(null)
  end if;
  return(cname)
end
