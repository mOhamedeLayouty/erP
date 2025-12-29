-- PF: UNKNOWN_SCHEMA.HIDE_FROM_NON_DBA
-- proc_id: 1
-- generated_at: 2025-12-29T13:53:28.689Z

create function SYS.HIDE_FROM_NON_DBA( in value long varchar ) 
returns long varchar
begin
  declare uid unsigned integer;
  select user_id into uid from SYS.ISYSUSER where user_name = current user;
  if exists(select * from SYS.ISYSUSERAUTHORITY
      where user_id = uid and auth = 'DBA') then
    return value
  else
    return '<hidden>'
  end if
end
