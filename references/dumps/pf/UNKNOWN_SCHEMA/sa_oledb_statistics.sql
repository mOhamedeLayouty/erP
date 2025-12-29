-- PF: UNKNOWN_SCHEMA.sa_oledb_statistics
-- proc_id: 299
-- generated_at: 2025-12-29T13:53:28.779Z

create procedure dbo.sa_oledb_statistics( 
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inTableName char(128) default '' ) 
result( 
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  CARDINALITY bigint ) dynamic result sets 1
on exception resume
begin
  if inTableCatalog = db_name() or inTableCatalog = '' then
    select db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      cast(count as bigint) as CARDINALITY
      from SYS.SYSTABLE
        join SYS.SYSUSERPERMS
      where user_name
       = if inTableSchema = '' then
        if inTableName = '' then user_name
        else dbo.sa_oledb_getowner('table',inTableName)
        endif
      else inTableSchema
      endif
      and table_name
       = if inTableName = '' then table_name
      else inTableName
      endif
      order by TABLE_CATALOG asc,TABLE_SCHEMA asc,TABLE_NAME asc
  else
    select null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as CARDINALITY
  end if
end
