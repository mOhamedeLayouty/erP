-- PF: UNKNOWN_SCHEMA.st_geometry_load_shapefile
-- proc_id: 270
-- generated_at: 2025-12-29T13:53:28.771Z

create procedure dbo.st_geometry_load_shapefile( 
  in shp_filename varchar(512),
  in srid integer,
  in table_name varchar(128),
  in table_owner varchar(128) default current user,
  in shp_encoding varchar(50) default 'ISO-8859-1' ) no result set
sql security invoker
begin
  declare @exec_sql TEXT;
  set @exec_sql = 'CREATE TABLE "' || table_owner || '"."'
     || table_name || '"( record_number INT PRIMARY KEY, '
     || (select LIST('"' || name || '" ' || domain_name_with_size,', ' order by
      column_number asc)
      from sa_describe_shapefile(shp_filename,srid,
        shp_encoding)
      where column_number > 1)
     || ' )';
  execute immediate @exec_sql;
  -- escape ' and \ to be inside a literal string
  set shp_filename = REPLACE(REPLACE(shp_filename,'''',''''''),
    '\\','\\\\');
  set @exec_sql = 'LOAD TABLE "' || table_owner || '"."' || table_name
     || '" USING FILE ''' || shp_filename || ''' FORMAT SHAPEFILE'
     || ' ENCODING ''' || shp_encoding || '''';
  execute immediate @exec_sql
end
