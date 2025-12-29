-- PF: UNKNOWN_SCHEMA.sp_password
-- proc_id: 19
-- generated_at: 2025-12-29T13:53:28.696Z

create procedure dbo.sp_password( 
  in @caller_pswd char(128),
  in @new_pswd char(128),
  in @login_name char(128) default null ) 
begin
  if @login_name is not null then
    if @login_name <> current user then
      call dbo.sp_checkperms('DBA')
    end if
  else
    set @login_name = current user
  end if;
  call dbo.sa_verify_password(isnull(@caller_pswd,''));
  execute immediate with quotes on 'grant connect to "'
     || @login_name || '" identified by "'
     || @new_pswd || '"'
end
