-- PF: UNKNOWN_SCHEMA.sa_oledb_getowner
-- proc_id: 305
-- generated_at: 2025-12-29T13:53:28.781Z

create function dbo.sa_oledb_getowner( 
  in object_type char(30),
  in object_name char(128) ) 
returns char(128)
begin
  declare owner_name char(128);
  declare num_objs integer;
  declare uid integer;
  declare i integer;
  declare ambig exception for sqlstate value '52W42';
  declare local temporary table owners(
    uid integer not null,
    user_name char(128) null,
    primary key(uid),
    ) in SYSTEM not transactional;
  set uid = (select user_id from SYS.SYSUSERPERM
      where user_name = current user);
  if object_type = 'table' then
    if exists(select * from SYS.SYSTABLE
        where table_name = object_name
        and creator = uid) then
      return current user
    end if
  elseif object_type = 'procedure' or object_type = 'function' then
    if exists(select * from SYS.SYSPROCEDURE
        where proc_name = object_name
        and creator = uid) then
      return current user
    end if
  else
    return null
  end if;
  insert into owners( uid ) with recursive
    temptab( group_member,group_id ) as(select root.group_member,root.group_id
      from SYS.SYSGROUP as root
      where root.group_member = uid union all
    select super.group_member,sub.group_id
      from SYS.SYSGROUP as sub,temptab as super
      where sub.group_member = super.group_id)
    select distinct final.group_id
      from temptab as final;
  update owners
    set owners.user_name = u.user_name from
    owners join SYS.SYSUSERPERM as u on(owners.uid = u.user_id);
  if object_type = 'table' then
    select max(user_name),count() into owner_name,num_objs
      from SYS.SYSTABLE as t
        join owners as o on(t.creator = o.uid)
      where table_name = object_name
  elseif object_type = 'procedure' or object_type = 'function' then
    select max(user_name),count() into owner_name,num_objs
      from SYS.SYSPROCEDURE as p
        join owners as o on(p.creator = o.uid)
      where proc_name = object_name
  end if;
  if num_objs > 1 then
    if object_type = 'table' then
      select max(user_name),count() into owner_name,num_objs
        from SYS.SYSTABLE as t
          join owners as o on(t.creator = o.uid)
        where compare(table_name,object_name,'UCA(case=respect)') = 0
    elseif object_type = 'procedure' or object_type = 'function' then
      select max(user_name),count() into owner_name,num_objs
        from SYS.SYSPROCEDURE as p
          join owners as o on(p.creator = o.uid)
        where compare(proc_name,object_name,'UCA(case=respect)') = 0
    end if
  end if;
  if num_objs > 1 then
    signal ambig
  end if;
  return owner_name
end
