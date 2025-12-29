-- PF: UNKNOWN_SCHEMA.sa_post_login_procedure
-- proc_id: 259
-- generated_at: 2025-12-29T13:53:28.768Z

create procedure dbo.sa_post_login_procedure()
result( message_text varchar(255),message_action integer ) dynamic result sets 1
begin
  declare message_text varchar(255);
  declare message_action integer;
  declare creation_date timestamp;
  declare life_time integer;
  declare grace_time integer;
  declare password_about_to_expire bit;
  set password_about_to_expire = 0;
  set creation_date = (select cast(password_creation_time as date)
      from SYS.SYSUSER
      where user_name = current user);
  set life_time = (select if login_option_value = 'unlimited' then-1 else login_option_value endif
      from SYS.SYSUSER as u
        key join SYS.SYSLOGINPOLICY as lp
        key join SYS.SYSLOGINPOLICYOPTION as lpo
      where user_name = current user
      and login_option_name = 'password_life_time');
  if life_time is null then
    set life_time = (select if login_option_value = 'unlimited' then-1 else login_option_value endif
        from SYS.SYSLOGINPOLICY as lp
          key join SYS.SYSLOGINPOLICYOPTION as lpo
        where login_policy_name = 'default'
        and login_option_name = 'password_life_time')
  end if;
  if life_time > 0 then
    set grace_time = (select if login_option_value = 'unlimited' then-1 else login_option_value endif
        from SYS.SYSUSER as u
          key join SYS.SYSLOGINPOLICY as lp
          key join SYS.SYSLOGINPOLICYOPTION as lpo
        where user_name = current user
        and login_option_name = 'password_grace_time');
    if grace_time is null then
      set grace_time = (select if login_option_value = 'unlimited' then-1 else login_option_value endif
          from SYS.SYSLOGINPOLICY as lp
            key join SYS.SYSLOGINPOLICYOPTION as lpo
          where login_policy_name = 'default'
          and login_option_name = 'password_grace_time')
    end if;
    if grace_time > 0 then
      if dateadd(day,life_time-grace_time,creation_date) <= current date then
        set password_about_to_expire = 1
      end if
    end if
  end if;
  if password_about_to_expire = 1 then
    set message_text = lang_message(17959);
    set message_action = 1
  else
    set message_text = null;
    set message_action = 0
  end if;
  -- return message (if any) through this result set
  select message_text,message_action
end
