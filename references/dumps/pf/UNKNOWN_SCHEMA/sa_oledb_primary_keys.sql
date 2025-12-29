-- PF: UNKNOWN_SCHEMA.sa_oledb_primary_keys
-- proc_id: 293
-- generated_at: 2025-12-29T13:53:28.778Z

create procedure dbo.sa_oledb_primary_keys( 
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inTableName char(128) default '' ) 
result( 
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  COLUMN_NAME char(128),
  COLUMN_GUID uniqueidentifier,
  COLUMN_PROPID unsigned integer,
  ORDINAL unsigned integer,
  PK_NAME char(128) ) dynamic result sets 1
on exception resume
begin
  if inTableCatalog = db_name() or inTableCatalog = '' then
    select db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      COLUMN_NAME,
      cast(null as uniqueidentifier) as COLUMN_GUID,
      cast(null as unsigned integer) as COLUMN_PROPID,
      cast((select count() from SYS.SYSCOLUMN as other
        where table_id = SYSTABLE.table_id
        and column_id <= SYSCOLUMN.column_id
        and pkey = 'Y') as smallint) as ORDINAL,
      SYSCONSTRAINT.constraint_name as PK_NAME
      from SYS.SYSCOLUMN
        join SYS.SYSTABLE
        join SYS.SYSUSERPERMS
        join SYS.SYSCONSTRAINT on(SYSTABLE.object_id = SYSCONSTRAINT.table_object_id)
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
      and pkey = 'Y'
      and constraint_type = 'P'
      order by 1 asc,2 asc,3 asc,5 asc
  else
    select null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as COLUMN_NAME,
      null as COLUMN_GUID,
      null as COLUMN_PROPID,
      null as ORDINAL,
      null as PK_NAME
  end if
end
