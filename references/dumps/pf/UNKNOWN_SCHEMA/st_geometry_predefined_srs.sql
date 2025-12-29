-- PF: UNKNOWN_SCHEMA.st_geometry_predefined_srs
-- proc_id: 268
-- generated_at: 2025-12-29T13:53:28.770Z

create procedure dbo.st_geometry_predefined_srs( in ddl_flag char(128) default null ) 
result( 
  srs_name char(128),
  srs_id integer,
  parent_srs_name char(128),
  round_earth char(1),xlo double,xhi double,ylo double,yhi double,zlo double,zhi double,mlo double,
  mhi double,organization long varchar,
  organization_coordsys_id integer,
  linear_unit_of_measure char(128),
  angular_unit_of_measure char(128),
  semi_major_axis double,
  inv_flattening double,
  semi_minor_axis double,
  wgs84_west_lon double,
  wgs84_south_lat double,
  wgs84_east_lon double,
  wgs84_north_lat double,
  definition long varchar,
  transform_definition long varchar,
  description long varchar,
  ddl long varchar,ddl_comment long varchar ) dynamic result sets 1
begin
  declare @newline char(1 char) = '\x0A';
  declare @tab char(1 char) = '\x09';
  select srs_name,srs_id,parent_srs_name,
    round_earth,
    xlo,xhi,ylo,yhi,zlo,zhi,mlo,mhi,
    organization,organization_coordsys_id,
    linear_unit_of_measure,angular_unit_of_measure,
    semi_major_axis,inv_flattening,semi_minor_axis,
    wgs84_west_lon,wgs84_south_lat,wgs84_east_lon,wgs84_north_lat,
    definition,transform_definition,
    description,
    ifnull(ddl_flag,null,
    string(
    case ddl_flag
    when 'ALTER' then ddl_flag
    when 'CREATE OR REPLACE' then ddl_flag
    else 'CREATE'
    end,
    ' SPATIAL REFERENCE SYSTEM',
    if ddl_flag = 'CREATE IF NOT EXISTS' then ' IF NOT EXISTS' else '' endif,
    '  "',srs_name,'"',
    @newline,@tab,'IDENTIFIED BY ',srs_id,
    @newline,@tab,'ORGANIZATION ''',organization,''' IDENTIFIED BY ',organization_coordsys_id,
    ifnull(linear_unit_of_measure,'',string(@newline,@tab,'LINEAR UNIT OF MEASURE "',linear_unit_of_measure,'"')),
    ifnull(angular_unit_of_measure,'',string(@newline,@tab,'ANGULAR UNIT OF MEASURE "',angular_unit_of_measure,'"')),
    @newline,@tab,if round_earth = 'Y' then 'TYPE ROUND EARTH' else 'TYPE PLANAR' endif,
    ifnull(semi_major_axis,'',string(@newline,@tab,'ELLIPSOID SEMI MAJOR AXIS ',semi_major_axis,' ',
    ifnull(semi_minor_axis,string('INVERSE FLATTENING ',inv_flattening),
    string('SEMI MINOR AXIS ',semi_minor_axis)))),
    ifnull(xlo,'',string(@newline,@tab,'COORDINATE X BETWEEN ',xlo,' AND ',xhi)),
    ifnull(ylo,'',string(@newline,@tab,'COORDINATE Y BETWEEN ',ylo,' AND ',yhi)),
    ifnull(zlo,'',string(@newline,@tab,'COORDINATE Z BETWEEN ',zlo,' AND ',zhi)),
    ifnull(mlo,'',string(@newline,@tab,'COORDINATE M BETWEEN ',mlo,' AND ',mhi)),
    ifnull(definition,'',string(@newline,@tab,'DEFINITION ''',replace(definition,'''',''''''),'''')),
    ifnull(transform_definition,'',string(@newline,@tab,'TRANSFORM DEFINITION ''',replace(transform_definition,'''',''''''),'''')))) as ddl,
    ifnull(ddl_flag,null,ifnull(description,null,
    string(
    'COMMENT ON SPATIAL REFERENCE SYSTEM "',srs_name,'" IS ',
    @newline,@tab,'''',replace(description,'''',''''''),''''))) as ddl_comment
    from openstring(value ST_Geometry::ST_LoadConfigurationData('epsg_srs.dat')) with(srs_name char(128),srs_id integer,parent_srs_name char(128),round_earth char(1),xlo double,xhi double,ylo double,yhi double,zlo double,zhi double,mlo double,mhi double,organization long varchar,organization_coordsys_id integer,linear_unit_of_measure char(128),angular_unit_of_measure char(128),semi_major_axis double,inv_flattening double,semi_minor_axis double,wgs84_west_lon double,wgs84_south_lat double,wgs84_east_lon double,wgs84_north_lat double,definition long varchar,transform_definition long varchar,description long varchar) as SRS
end
