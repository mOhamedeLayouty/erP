-- PF: UNKNOWN_SCHEMA.sa_conn_options
-- proc_id: 63
-- generated_at: 2025-12-29T13:53:28.709Z

create procedure dbo.sa_conn_options( in connidparm integer default null ) 
result( 
  Number integer,
  PropNum integer,
  OptionName varchar(255),
  OptionDescription varchar(255),
  Value long varchar ) dynamic result sets 1
begin
  select Number,
    row_num as PropNum,
    property_name(PropNum) as OptionName,
    property_description(PropNum) as OptionDescription,
    connection_property(PropNum,Number) as Value
    from dbo.sa_rowgenerator(property('FirstOption'),property('LastOption'))
      ,dbo.sa_conn_list(connidparm,-1)
    where OptionName is not null
    and Value is not null
end
