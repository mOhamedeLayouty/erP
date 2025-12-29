-- PF: UNKNOWN_SCHEMA.sp_setreptable
-- proc_id: 154
-- generated_at: 2025-12-29T13:53:28.737Z

create procedure dbo.sp_setreptable( 
  in @table_name char(128),
  in @true_false char(5) ) 
begin
  declare owner_name char(128);
  declare qualified_name char(250);
  declare stmt char(300);
  declare first_owner dynamic scroll cursor for
    select user_name
      from SYS.SYSTAB as t,SYS.SYSUSER as u
      where table_name = @table_name and t.creator = u.user_id;
  set owner_name = '';
  open first_owner;
  fetch next first_owner into owner_name;
  if sqlcode = 0 then
    set owner_name = rtrim(owner_name)
  end if;
  close first_owner;
  set qualified_name = '"' || owner_name || '"."' || @table_name || '"';
  if exists(select * from dbo.sysobjects
      where name = @table_name and type = 'U') then
    if lcase(@true_false) = 'true' then
      set stmt = 'alter table ' || qualified_name || ' replicate on'
    elseif lcase(@true_false) = 'false' then
      set stmt = 'alter table ' || qualified_name || ' replicate off'
    else
      raiserror 18100 'Usage: call sp_setreptable( table_name, {true | false} )';
      return
    end if;
    execute immediate with quotes on stmt
  else
    raiserror 18102 'Table ''' || @table_name || ''' does not exist in this database'
  end if
end
