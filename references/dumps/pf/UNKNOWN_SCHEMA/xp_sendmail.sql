-- PF: UNKNOWN_SCHEMA.xp_sendmail
-- proc_id: 48
-- generated_at: 2025-12-29T13:53:28.705Z

create function dbo.xp_sendmail( 
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
  in content_type long varchar default null ) 
returns integer
on exception resume
begin
  declare recip long varchar;
  declare subj long varchar;
  declare cc long varchar;
  declare bcc long varchar;
  declare qry long varchar;
  declare msg long varchar;
  declare "attach" long varchar;
  declare include long varchar;
  declare cont_type long varchar;
  declare cid integer;
  set recip = cast(csconvert(recipient,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set recip = recipient
  end if;
  set subj = cast(csconvert(subject,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set subj = subject
  end if;
  set cc = cast(csconvert(cc_recipient,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set cc = cc_recipient
  end if;
  set bcc = cast(csconvert(bcc_recipient,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set bcc = bcc_recipient
  end if;
  set qry = cast(csconvert(query,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set qry = query
  end if;
  set msg = cast(csconvert("message",'os_charset') as long varchar);
  if sqlcode <> 0 then
    set msg = "message"
  end if;
  set "attach" = cast(csconvert(attachname,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set "attach" = attachname
  end if;
  set include = cast(csconvert(include_file,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set include = include_file
  end if;
  set cont_type = cast(csconvert(content_type,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set cont_type = content_type
  end if;
  set cid = connection_property('Number');
  return(xp_real_sendmail(recip,subj,cc,bcc,qry,msg,"attach",
    attach_result,echo_error,include,no_column_header,
    no_output,width,separator,dbuser,dbname,type,
    include_query,cont_type,cid))
end
