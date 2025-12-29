-- PF: UNKNOWN_SCHEMA.xp_startmail
-- proc_id: 40
-- generated_at: 2025-12-29T13:53:28.703Z

create function dbo.xp_startmail( 
  in mail_user long varchar default null,
  in mail_password long varchar default null ) 
returns integer
on exception resume
begin
  declare u long varchar;
  declare p long varchar;
  declare cid integer;
  set u = cast(csconvert(mail_user,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set u = mail_user
  end if;
  set p = cast(csconvert(mail_password,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set p = mail_password
  end if;
  set cid = connection_property('Number');
  return(dbo.xp_real_startmail(u,p,cid))
end
