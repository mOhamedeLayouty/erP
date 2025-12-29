-- PF: UNKNOWN_SCHEMA.sa_db_info
-- proc_id: 68
-- generated_at: 2025-12-29T13:53:28.711Z

create procedure dbo.sa_db_info( in dbidparm integer default null ) 
result( 
  Number integer,
  Alias varchar(255),
  File varchar(255),
  ConnCount integer,
  PageSize integer,
  LogName varchar(255) ) dynamic result sets 1
begin
  select Number,
    db_property('Alias',Number),
    db_property('File',Number),
    db_property('ConnCount',Number),
    db_property('PageSize',Number),
    db_property('LogName',Number)
    from dbo.sa_db_list(dbidparm)
end
