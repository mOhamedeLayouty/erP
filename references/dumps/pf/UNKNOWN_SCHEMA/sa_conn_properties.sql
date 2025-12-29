-- PF: UNKNOWN_SCHEMA.sa_conn_properties
-- proc_id: 62
-- generated_at: 2025-12-29T13:53:28.709Z

create procedure dbo.sa_conn_properties( in connidparm integer default null ) 
result( 
  Number integer,
  PropNum integer,
  PropName varchar(255),
  PropDescription varchar(255),
  Value long varchar ) dynamic result sets 1
begin
  select Number,
    row_num as id,
    property_name(id,'connection') as name,
    property_description(id),
    connection_property(id,Number) as val
    from dbo.sa_rowgenerator(0,property('LastConnectionProperty'))
      ,dbo.sa_conn_list(connidparm,-1)
    where name is not null
end
