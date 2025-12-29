-- PF: UNKNOWN_SCHEMA.sa_conn_activity
-- proc_id: 64
-- generated_at: 2025-12-29T13:53:28.709Z

create procedure dbo.sa_conn_activity( in connidparm integer default null ) 
result( 
  Number integer,
  Name varchar(255),
  Userid varchar(255),
  DBNumber integer,
  LastReqTime varchar(255),
  LastStatement long varchar ) dynamic result sets 1
begin
  select Number,
    connection_property('Name',Number),
    connection_property('Userid',Number),
    connection_property('DBNumber',Number),
    connection_property('LastReqTime',Number),
    connection_property('LastStatement',Number)
    from dbo.sa_conn_list(connidparm,null)
end
