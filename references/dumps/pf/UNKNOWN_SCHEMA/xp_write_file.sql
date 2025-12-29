-- PF: UNKNOWN_SCHEMA.xp_write_file
-- proc_id: 55
-- generated_at: 2025-12-29T13:53:28.707Z

create function dbo.xp_write_file( 
  in filename long varchar,
  in file_contents long binary ) 
returns integer
on exception resume
begin
  declare fname long varchar;
  set fname = cast(csconvert(filename,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set fname = filename
  end if;
  return(dbo.xp_real_write_file(fname,file_contents))
end
