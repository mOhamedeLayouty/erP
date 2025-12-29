-- PF: UNKNOWN_SCHEMA.xp_real_startmail
-- proc_id: 39
-- generated_at: 2025-12-29T13:53:28.702Z

create function dbo.xp_real_startmail( 
  in mail_user long varchar default null,
  in mail_password long varchar default null,
  in cid integer ) 
returns integer
external name 'xp_startmail@dbextf.dll'
