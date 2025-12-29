-- PF: UNKNOWN_SCHEMA.object_id
-- proc_id: 35
-- generated_at: 2025-12-29T13:53:28.701Z

create function dbo.object_id( in @object_name char(257) ) 
returns integer
on exception resume
begin
  declare obj_owner char(128);
  declare obj_name char(128);
  declare id integer;
  declare posn integer;
  set posn = locate(@object_name,'.');
  if(posn <> 0) then
    set obj_owner = lower(substr(@object_name,1,posn-1));
    set obj_name = lower(substr(@object_name,posn+1))
  else
    set obj_owner = lower(current user);
    set obj_name = lower(@object_name)
  end if;
  select o.id
    into id from dbo.sysobjects as o,SYS.SYSUSER as u
    where lower(o.name) = obj_name
    and o.uid = u.user_id
    and lower(u.user_name) = obj_owner;
  return(id)
end
