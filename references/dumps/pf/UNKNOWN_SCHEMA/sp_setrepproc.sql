-- PF: UNKNOWN_SCHEMA.sp_setrepproc
-- proc_id: 155
-- generated_at: 2025-12-29T13:53:28.738Z

create procedure dbo.sp_setrepproc( 
  in @proc_name char(128),
  in @true_false char(5) ) 
begin
  declare owner_name char(128);
  declare qualified_name char(250);
  declare stmt char(300);
  declare first_owner dynamic scroll cursor for
    select user_name
      from SYS.SYSPROCEDURE as t,SYS.SYSUSER as u
      where proc_name = @proc_name and t.creator = u.user_id;
  set owner_name = '';
  open first_owner;
  fetch next first_owner into owner_name;
  if sqlcode = 0 then
    set owner_name = rtrim(owner_name)
  end if;
  close first_owner;
  set qualified_name = '"' || owner_name || '"."' || @proc_name || '"';
  if exists(select * from dbo.sysobjects
      where name = @proc_name and type = 'P') then
    if lcase(@true_false) = 'true' then
      set stmt = 'alter procedure ' || qualified_name || ' replicate on'
    elseif lcase(@true_false) = 'false' then
      set stmt = 'alter procedure ' || qualified_name || ' replicate off'
    else
      raiserror 18100 'Usage: call sp_setrepproc( proc_name, {true | false} )';
      return
    end if;
    execute immediate with quotes on stmt
  else
    raiserror 18107 'Stored procedure ''' || @proc_name || ''' does not exist in this database'
  end if
end
