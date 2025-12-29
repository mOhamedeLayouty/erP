-- PF: UNKNOWN_SCHEMA.sa_get_table_definition
-- proc_id: 264
-- generated_at: 2025-12-29T13:53:28.769Z

create function dbo.sa_get_table_definition( in @owner varchar(128),in @tabname varchar(128) ) 
returns long varchar
begin
  declare @result long varchar;
  if not exists(select *
      from SYS.SYSTAB as t join SYS.SYSUSER as u on(t.creator = u.user_id)
      where user_name = @owner
      and table_name = @tabname
      and table_type_str in( 'BASE','GBL TEMP' ) ) then
    return null
  end if;
  call dbo.sa_exec_script('unload.sql');
  set @result = f_unload_one_table(@owner,@tabname);
  call sa_unload_drop_all();
  drop procedure sa_unload_drop_all;
  return @result
end
