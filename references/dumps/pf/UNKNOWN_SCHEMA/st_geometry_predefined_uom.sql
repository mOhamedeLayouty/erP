-- PF: UNKNOWN_SCHEMA.st_geometry_predefined_uom
-- proc_id: 267
-- generated_at: 2025-12-29T13:53:28.770Z

create procedure dbo.st_geometry_predefined_uom( in ddl_flag char(128) default null ) 
result( unit_name char(128),unit_type char(128),conversion_factor double,
  description long varchar,ddl long varchar,ddl_comment long varchar ) dynamic result sets 1
begin
  select unit_name,unit_type,conversion_factor,description,
    ifnull(ddl_flag,null,
    string(
    case ddl_flag
    when 'ALTER' then ddl_flag
    when 'CREATE OR REPLACE' then ddl_flag
    else 'CREATE'
    end,
    ' SPATIAL UNIT OF MEASURE',
    if ddl_flag = 'CREATE IF NOT EXISTS' then ' IF NOT EXISTS' else '' endif,
    '  "',unit_name,'"',
    '\x0A\x09TYPE ',unit_type,
    '\x0A\x09CONVERT USING ',conversion_factor)) as ddl,
    ifnull(ddl_flag,null,ifnull(description,null,
    string(
    'COMMENT ON SPATIAL UNIT OF MEASURE "',unit_name,'" IS ',
    '\x0A\x09''',replace(description,'''',''''''),''''))) as ddl_comment
    from openstring(value ST_Geometry::ST_LoadConfigurationData('epsg_uom.dat')) with(unit_name char(128),unit_type char(128),conversion_factor double,description long varchar) as UOM
end
