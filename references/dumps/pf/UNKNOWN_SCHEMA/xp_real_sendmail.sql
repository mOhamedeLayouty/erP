-- PF: UNKNOWN_SCHEMA.xp_real_sendmail
-- proc_id: 47
-- generated_at: 2025-12-29T13:53:28.704Z

create function dbo.xp_real_sendmail( 
  in recipient long varchar,
  in subject long varchar default null,
  in cc_recipient long varchar default null,
  in bcc_recipient long varchar default null,
  in query long varchar default null,
  in "message" long varchar default null,
  in attachname long varchar default null,
  in attach_result integer default 0,
  in echo_error integer default 1,
  in include_file long varchar default null,
  in no_column_header integer default 0,
  in no_output integer default 0,
  in width integer default 80,
  in separator char(1) default "char"(9),
  in dbuser long varchar default 'guest',
  in dbname long varchar default 'master',
  in type long varchar default null,
  in include_query integer default 0,
  in content_type long varchar default null,
  in cid integer ) 
returns integer
external name 'xp_sendmail@dbextf;Unix:xp_sendmail@libdbextf'
