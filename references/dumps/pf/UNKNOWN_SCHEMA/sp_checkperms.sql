-- PF: UNKNOWN_SCHEMA.sp_checkperms
-- proc_id: 3
-- generated_at: 2025-12-29T13:53:28.691Z

create procedure dbo.sp_checkperms( in required_auth char(10) ) 
begin
  declare uid unsigned integer;
  declare permission_denied exception for sqlstate value '42501';
  select user_id into uid from SYS.SYSUSER where user_name = current user;
  if exists(select * from SYS.SYSUSERAUTHORITY
      where user_id = uid
      and auth = 'DBA') then
    -- User has sufficient permissions
    return
  end if;
  if required_auth <> 'DBA' then
    if exists(select * from SYS.SYSUSERAUTHORITY
        where user_id = uid
        and auth = required_auth) then
      -- User has sufficient permissions
      return
    end if
  end if;
  signal permission_denied
end
