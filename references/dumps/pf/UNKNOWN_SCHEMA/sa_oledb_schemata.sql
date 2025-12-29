-- PF: UNKNOWN_SCHEMA.sa_oledb_schemata
-- proc_id: 298
-- generated_at: 2025-12-29T13:53:28.779Z

create procedure dbo.sa_oledb_schemata( 
  in inCatalogName char(128) default '',
  in inSchemaName char(128) default '',
  in inSchemaOwner char(128) default '' ) 
result( 
  CATALOG_NAME char(128),
  SCHEMA_NAME char(128),
  SCHEMA_OWNER char(128),
  DEFAULT_CHARACTER_SET_CATALOG char(128),
  DEFAULT_CHARACTER_SET_SCHEMA char(128),
  DEFAULT_CHARACTER_SET_NAME char(128) ) dynamic result sets 1
on exception resume
begin
  select distinct
    db_name() as CATALOG_NAME,
    creator as SCHEMA_NAME,
    creator as SCHEMA_OWNER,
    db_name() as DEFAULT_CHARACTER_SET_CATALOG,
    'SYS' as DEFAULT_CHARACTER_SET_SCHEMA,
    db_property('CharSet') as DEFAULT_CHARACTER_SET_NAME
    from SYS.SYSCATALOG
    where CATALOG_NAME
     = if inCatalogName = '' then CATALOG_NAME
    else inCatalogName
    endif
    and SCHEMA_NAME
     = if inSchemaName = '' then SCHEMA_NAME
    else inSchemaName
    endif
    and SCHEMA_OWNER
     = if inSchemaOwner = '' then SCHEMA_OWNER
    else inSchemaOwner
    endif
    order by CATALOG_NAME asc,SCHEMA_NAME asc,SCHEMA_OWNER asc
end
