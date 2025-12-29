-- PF: UNKNOWN_SCHEMA.object_name
-- proc_id: 36
-- generated_at: 2025-12-29T13:53:28.702Z

create function dbo.object_name( 
  in @object_id integer,
  in @database_id integer default null ) 
returns char(128)
on exception resume
begin
  declare obj_name char(128);
  select name
    into obj_name from dbo.sysobjects
    where id = @object_id;
  return(obj_name)
end
