-- PF: UNKNOWN_SCHEMA.sa_conn_list
-- proc_id: 60
-- generated_at: 2025-12-29T13:53:28.708Z

create procedure dbo.sa_conn_list( in connidparm integer default null,in dbidparm integer default null ) 
result( Number integer ) dynamic result sets 1
begin
  declare connid integer;
  declare dbid integer;
  declare local temporary table t_conn_list(
    Number integer not null,
    ) in SYSTEM not transactional;
  if(connidparm < 0) then
    insert into t_conn_list values( connection_property('Number') ) 
  elseif(connidparm is not null) then
    insert into t_conn_list values( connidparm ) 
  else
    if dbidparm < 0 then
      set dbid = connection_property('DBNumber')
    else
      set dbid = dbidparm
    end if;
    set connid = next_connection(null,dbid);
    while(connid is not null) loop
      insert into t_conn_list values( connid ) ;
      set connid = next_connection(connid,dbid)
    end loop
  end if;
  select * from t_conn_list
end
