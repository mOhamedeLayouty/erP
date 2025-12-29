-- PF: UNKNOWN_SCHEMA.sp_adduser
-- proc_id: 8
-- generated_at: 2025-12-29T13:53:28.693Z

create procedure dbo.sp_adduser( 
  in @login_name char(128),
  in @name_in_db char(128) default null,
  in @grpname char(128) default null ) 
begin
  call dbo.sp_checkperms('DBA');
  if not exists(select * from SYS.SYSUSER
      where user_name = @login_name) then
    execute immediate with quotes on
      'grant connect to "' || @login_name || '"'
  else
    raiserror 17330 'A user with the same name already exists in the database'
  end if;
  if @grpname is not null then
    execute immediate with quotes on
      'grant membership in group "' || @grpname
       || '" to "' || @login_name || '"'
  end if
end
