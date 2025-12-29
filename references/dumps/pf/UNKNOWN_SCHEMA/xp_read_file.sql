-- PF: UNKNOWN_SCHEMA.xp_read_file
-- proc_id: 57
-- generated_at: 2025-12-29T13:53:28.707Z

create function dbo.xp_read_file( in filename long varchar,in lazy integer default 0 ) 
returns long binary
on exception resume
begin
  declare fname long varchar;
  declare contents long binary;
  set fname = cast(csconvert(filename,'os_charset') as long varchar);
  if sqlcode <> 0 then
    set fname = filename
  end if;
  call dbo.xp_real_read_file(fname,contents,lazy);
  return(contents)
end
