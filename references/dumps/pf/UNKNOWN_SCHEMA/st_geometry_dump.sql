-- PF: UNKNOWN_SCHEMA.st_geometry_dump
-- proc_id: 269
-- generated_at: 2025-12-29T13:53:28.771Z

create procedure dbo.st_geometry_dump( in geo ST_Geometry,
  in "options" varchar(255) default null ) 
result( 
  id unsigned bigint,
  parent_id unsigned bigint,
  depth integer,
  format varchar(128),
  valid bit,
  geom_type varchar(128),
  geom ST_Geometry,
  xmin double,
  xmax double,
  ymin double,
  ymax double,
  zmin double,
  zmax double,
  mmin double,
  mmax double,
  details long varchar ) dynamic result sets 1
internal name 'st_geometry_dump'
