-- PF: UNKNOWN_SCHEMA.sa_db_properties
-- proc_id: 69
-- generated_at: 2025-12-29T13:53:28.711Z

create procedure dbo.sa_db_properties( in dbidparm integer default null ) 
result( 
  Number integer,
  PropNum integer,
  PropName varchar(255),
  PropDescription varchar(255),
  Value long varchar ) dynamic result sets 1
begin
  select Number,
    row_num as PropNum,
    property_name(PropNum,'database') as PropName,
    property_description(PropNum) as PropDescription,
    db_property(PropNum,Number) as Value
    from dbo.sa_rowgenerator(0,property('LastDatabaseProperty'))
      ,dbo.sa_db_list(dbidparm)
    where PropName is not null
end
