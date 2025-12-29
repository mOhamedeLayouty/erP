-- PF: UNKNOWN_SCHEMA.sa_oledb_catalogs
-- proc_id: 288
-- generated_at: 2025-12-29T13:53:28.776Z

create procedure dbo.sa_oledb_catalogs( 
  in inCatalogName char(128) default '' ) 
result( 
  CATALOG_NAME char(128),
  DESCRIPTION varchar(254) ) dynamic result sets 1
on exception resume
begin
  declare iter integer;
  declare local temporary table oledb_catalog(
    catalog_name char(128) null,
    description varchar(254) null default null,) in SYSTEM not transactional;set iter = 0;
  while iter < 255 loop
    insert into oledb_catalog( catalog_name,description ) values
      ( db_name(iter),db_property('File',iter) ) ;
    set iter = iter+1
  end loop;
  select catalog_name,description
    from oledb_catalog
    where catalog_name is not null
    and catalog_name
     = if inCatalogName = '' then catalog_name
    else inCatalogName
    endif
    order by catalog_name asc
end
