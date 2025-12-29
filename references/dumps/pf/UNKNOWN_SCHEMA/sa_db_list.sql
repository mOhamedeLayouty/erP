-- PF: UNKNOWN_SCHEMA.sa_db_list
-- proc_id: 67
-- generated_at: 2025-12-29T13:53:28.710Z

create procedure dbo.sa_db_list( in dbidparm integer default null ) 
result( Number integer ) dynamic result sets 1
begin
  declare dbid integer;
  declare local temporary table t_db_list(
    Number integer not null,
    ) in SYSTEM not transactional;
  if(dbidparm < 0) then
    insert into t_db_list values( connection_property('DBNumber') ) 
  elseif(dbidparm is not null) then
    insert into t_db_list values( dbidparm ) 
  else
    set dbid = next_database(null);
    while(dbid is not null) loop
      insert into t_db_list values( dbid ) ;
      set dbid = next_database(dbid)
    end loop
  end if;
  select * from t_db_list
end
