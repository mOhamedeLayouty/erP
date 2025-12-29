-- PF: UNKNOWN_SCHEMA.xp_real_cmdshell
-- proc_id: 49
-- generated_at: 2025-12-29T13:53:28.705Z

create function dbo.xp_real_cmdshell( 
  in command varchar(8000) default null,
  in redir_output char(254) default '' ) 
returns integer
internal name 'xp_real_cmdshell'
