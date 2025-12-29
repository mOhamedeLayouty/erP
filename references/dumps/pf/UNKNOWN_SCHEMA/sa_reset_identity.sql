-- PF: UNKNOWN_SCHEMA.sa_reset_identity
-- proc_id: 94
-- generated_at: 2025-12-29T13:53:28.719Z

create procedure dbo.sa_reset_identity( 
  in tbl_name char(128),
  in owner_name char(128) default null,
  in new_identity bigint default null ) 
begin
  declare tname char(128);
  declare uname char(128);
  declare num_tables integer;
  if new_identity is null then
    raiserror 20002 'invalid new_identity value';
    return
  end if;
  if tbl_name is null then
    raiserror 20003 'missing table name';
    return
  end if;
  set tname = rtrim(tbl_name);
  if owner_name is null then
    select count()
      into num_tables from SYS.SYSTAB
      where table_name = tname;
    if num_tables > 1 then
      raiserror 20004 'ambiguous table name';
      return
    end if;
    select rtrim(user_name)
      into uname from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_name = tname
      and t.creator = u.user_id
  else
    set uname = rtrim(owner_name)
  end if;
  call dbo.sa_internal_reset_identity(tname,uname,new_identity);
  checkpoint
end
