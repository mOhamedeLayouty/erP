-- PF: UNKNOWN_SCHEMA.sp_addlogin
-- proc_id: 5
-- generated_at: 2025-12-29T13:53:28.691Z

create procedure dbo.sp_addlogin( 
  in @login_name char(128),
  in @passwd char(128),
  in @defaultdb char(128) default null,
  in @deflanguage char(30) default null,
  in @fullname char(128) default null ) 
begin
  call dbo.sp_checkperms('DBA');
  if not exists(select * from SYS.SYSUSER where user_name = @login_name) then
    execute immediate with quotes on 'grant connect to "'
       || @login_name || '" identified by "' || @passwd || '"'
  else
    raiserror 17262 'A user with the specified login name already exists'
  end if
end
