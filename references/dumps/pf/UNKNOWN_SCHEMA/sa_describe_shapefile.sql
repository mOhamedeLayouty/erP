-- PF: UNKNOWN_SCHEMA.sa_describe_shapefile
-- proc_id: 265
-- generated_at: 2025-12-29T13:53:28.770Z

create procedure dbo.sa_describe_shapefile( in shp_filename varchar(512),
  in srid integer,
  in encoding varchar(50) default null ) 
result( 
  column_number integer,
  name varchar(128),
  domain_name_with_size varchar(160) ) dynamic result sets 1
internal name 'sa_describe_shapefile'
