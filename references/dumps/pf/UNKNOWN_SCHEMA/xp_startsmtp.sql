-- PF: UNKNOWN_SCHEMA.xp_startsmtp
-- proc_id: 44
-- generated_at: 2025-12-29T13:53:28.704Z

create function dbo.xp_startsmtp( 
  in smtp_sender long varchar,
  in smtp_server long varchar,
  in smtp_port integer default 25,
  in timeout integer default 60,
  in smtp_sender_name long varchar default null,
  in smtp_auth_username long varchar default null,
  in smtp_auth_password long varchar default null,
  in trusted_certificates long varchar default null,
  in certificate_company long varchar default null,
  in certificate_unit long varchar default null,
  in certificate_name long varchar default null ) 
returns integer
on exception resume
begin
  declare sender long varchar;
  declare server long varchar;
  declare sender_name long varchar;
  declare auth_username long varchar;
  declare auth_password long varchar;
  declare trusted_cert long varchar;
  declare cert_company long varchar;
  declare cert_unit long varchar;
  declare cert_name long varchar;
  declare cid integer;
  set sender = cast(csconvert(smtp_sender,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set sender = smtp_sender
  end if;
  set server = cast(csconvert(smtp_server,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set server = smtp_server
  end if;
  set sender_name = cast(csconvert(smtp_sender_name,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set sender_name = smtp_sender_name
  end if;
  set auth_username = cast(csconvert(smtp_auth_username,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set auth_username = smtp_auth_username
  end if;
  set auth_password = cast(csconvert(smtp_auth_password,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set auth_password = smtp_auth_password
  end if;
  set trusted_cert = cast(csconvert(trusted_certificates,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set trusted_cert = trusted_certificates
  end if;
  set cert_company = cast(csconvert(certificate_company,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set cert_company = certificate_company
  end if;
  set cert_unit = cast(csconvert(certificate_unit,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set cert_unit = certificate_unit
  end if;
  set cert_name = cast(csconvert(certificate_name,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set cert_name = certificate_name
  end if;
  set cid = connection_property('Number');
  return(dbo.xp_real_startsmtp(sender,server,smtp_port,timeout,
    sender_name,auth_username,auth_password,trusted_cert,
    cert_company,cert_unit,cert_name,cid))
end
