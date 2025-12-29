-- PF: UNKNOWN_SCHEMA.sa_oledb_views
-- proc_id: 304
-- generated_at: 2025-12-29T13:53:28.781Z

create procedure dbo.sa_oledb_views( 
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inTableName char(128) default '' ) 
result( 
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  VIEW_DEFINITION varchar(8192),
  CHECK_OPTION bit,
  IS_UPDATABLE bit,
  DESCRIPTION varchar(254),
  DATE_CREATED timestamp,
  DATE_MODIFIED timestamp ) dynamic result sets 1
on exception resume
begin
  if inTableCatalog = db_name() or inTableCatalog = '' then
    select db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      SYSTABLE.view_def as VIEW_DEFINITION,
      cast(1 as bit) as CHECK_OPTION,
      cast(0 as bit) as IS_UPDATABLE,
      cast(SYSTABLE.remarks as varchar(254)) as DESCRIPTION,
      cast(null as timestamp) as DATE_CREATED,
      cast(null as timestamp) as DATE_MODIFIED
      from SYS.SYSTABLE join SYS.SYSUSERPERMS
      where table_type in( 'VIEW','MAT VIEW' ) 
      and user_name
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
      order by 4 asc,1 asc,2 asc,3 asc
  else
    select null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as VIEW_DEFINITION,
      null as CHECK_OPTION,
      null as IS_UPDATABLE,
      null as DESCRIPTION,
      null as DATE_CREATED,
      null as DATE_MODIFIED
  end if
end
