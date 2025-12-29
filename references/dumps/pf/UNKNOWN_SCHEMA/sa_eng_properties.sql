-- PF: UNKNOWN_SCHEMA.sa_eng_properties
-- proc_id: 66
-- generated_at: 2025-12-29T13:53:28.710Z

create procedure dbo.sa_eng_properties()
result( 
  PropNum integer,
  PropName varchar(255),
  PropDescription varchar(255),
  Value long varchar ) dynamic result sets 1
begin
  select row_num as PropNum,
    property_name(PropNum,'server') as PropName,
    property_description(PropNum) as PropDescription,
    property(PropNum) as Value
    from dbo.sa_rowgenerator(0,property('LastServerProperty'))
    where PropName is not null
end
