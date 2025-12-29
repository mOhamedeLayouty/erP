-- PF: UNKNOWN_SCHEMA.sa_migrate_create_proxy_tables
-- proc_id: 313
-- generated_at: 2025-12-29T13:53:28.784Z

create procedure dbo.sa_migrate_create_proxy_tables( 
  in i_action varchar(20),
  in i_table_owner varchar(128) ) 
begin
  declare stmt long varchar;
  for tl as tlc dynamic scroll cursor for
    select table_id as o_id,
      server_name+';'+database_name+';'+owner_name+';'+table_name as rem_location,
      '"'+i_table_owner+'"'+'.'+'"'+table_name+'_et'+'"' as tabname
      from dbo.migrate_remote_table_list
      where case created_proxy
      when 0 then 'CREATE'
      when 1 then 'DROP'
      else 'UNKNOWN'
      end = i_action
  do
    if(i_action = 'CREATE') then
      -- Create the table with an '_et' on the end to
      -- indicate it is an existing table
      set stmt = 'CREATE EXISTING TABLE '+tabname
        +' AT '''+rem_location+'''';
      message stmt to client;
      update dbo.migrate_remote_table_list
        set created_proxy = 1,dropped = 0
        where table_id = o_id
    elseif(i_action = 'DROP') then
      set stmt = 'DROP TABLE ' || tabname;
      message stmt to client;
      update dbo.migrate_remote_table_list
        set created_proxy = 0,dropped = 1
        where table_id = o_id
    end if;
    execute immediate stmt
  end for
end
