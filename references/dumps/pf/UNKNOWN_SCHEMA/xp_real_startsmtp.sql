-- PF: UNKNOWN_SCHEMA.xp_real_startsmtp
-- proc_id: 43
-- generated_at: 2025-12-29T13:53:28.703Z

create function dbo.xp_real_startsmtp( 
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
  in certificate_name long varchar default null,
  in cid integer ) 
returns integer
external name 'xp_startsmtp@dbextf;Unix:xp_startsmtp@libdbextf'
