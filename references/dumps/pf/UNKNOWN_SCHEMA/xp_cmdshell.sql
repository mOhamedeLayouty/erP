-- PF: UNKNOWN_SCHEMA.xp_cmdshell
-- proc_id: 50
-- generated_at: 2025-12-29T13:53:28.705Z

create function dbo.xp_cmdshell( 
  in command varchar(8000) default null,
  in redir_output char(254) default '' ) 
returns integer
on exception resume
begin
  declare cmd varchar(8000);
  declare redir char(254);
  set cmd = cast(csconvert(command,'os_charset') as varchar(8000));
  if sqlcode <> 0 then
    set cmd = command
  end if;
  set redir = cast(csconvert(redir_output,'os_charset') as char(254));
  if sqlcode <> 0 then
    set redir = redir_output
  end if;
  return(dbo.xp_real_cmdshell(cmd,redir))
end
