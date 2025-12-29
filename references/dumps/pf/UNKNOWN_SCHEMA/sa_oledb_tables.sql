-- PF: UNKNOWN_SCHEMA.sa_oledb_tables
-- proc_id: 302
-- generated_at: 2025-12-29T13:53:28.780Z

create procedure dbo.sa_oledb_tables( 
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inTableName char(128) default '',
  in inTableType char(128) default '' ) 
result( 
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  TABLE_TYPE char(20),
  TABLE_GUID uniqueidentifier,
  DESCRIPTION varchar(254),
  TABLE_PROPID unsigned integer,
  DATE_CREATED timestamp,
  DATE_MODIFIED timestamp ) dynamic result sets 1
on exception resume
begin
  declare isSysOwned char(20);
  set isSysOwned = '';
  if inTableType = 'GLOBAL TEMPORARY' then
    set inTableType = 'GBL TEMP'
  elseif inTableType = 'LOCAL TEMPORARY' then
    set inTableType = 'TEMP'
  else
    set isSysOwned = substring(inTableType,1,7);
    if isSysOwned = 'SYSTEM ' then
      set inTableType = substring(inTableType,8);
      if inTableType = 'TABLE' then
        set inTableType = 'BASE'
      end if
    else set isSysOwned = ''
    end if end if;
  if inTableCatalog = db_name() or inTableCatalog = '' then
    select TABLE_CATALOG,
      TABLE_SCHEMA,
      TABLE_NAME,
      TABLE_TYPE,
      TABLE_GUID,
      DESCRIPTION,
      TABLE_PROPID,
      DATE_CREATED,
      DATE_MODIFIED
      from(select db_name() as TABLE_CATALOG,
          SYSUSERPERMS.user_name as TABLE_SCHEMA,
          SYSTABLE.table_name as TABLE_NAME,
          cast(case user_name
          when 'SYS' then 'SYSTEM '
          when 'ml_server' then 'SYSTEM '
          when 'rs_systabgroup' then 'SYSTEM '
          when 'dbo' then
            if(table_name = any(select name from EXCLUDEOBJECT)) then
              'SYSTEM '
            else ''
            endif
          else ''
          end as char(20)) as PREFIXSYSOWNED,
          cast(case table_type
          when 'BASE' then string(PREFIXSYSOWNED,'TABLE')
          when 'VIEW' then string(PREFIXSYSOWNED,'VIEW')
          when 'MAT VIEW' then string(PREFIXSYSOWNED,'VIEW')
          when 'TEXT' then string(PREFIXSYSOWNED,'TEXT')
          when 'GBL TEMP' then 'GLOBAL TEMPORARY'
          else 'LOCAL TEMPORARY'
          end as char(20)) as TABLE_TYPE,
          cast(null as uniqueidentifier) as TABLE_GUID,
          cast(SYSTABLE.remarks as varchar(254)) as DESCRIPTION,
          cast(null as integer) as TABLE_PROPID,
          cast(null as timestamp) as DATE_CREATED,
          cast(null as timestamp) as DATE_MODIFIED
          from SYS.SYSTABLE
            join SYS.SYSUSERPERMS
          where user_name
           = if inTableSchema = '' then
            if inTableName = '' then user_name
            else dbo.sa_oledb_getowner('table',inTableName)
            endif
          else inTableSchema
          endif
          and TABLE_NAME
           = if inTableName = '' then TABLE_NAME
          else inTableName
          endif
          and TABLE_TYPE
           = if inTableType = '' then TABLE_TYPE
          else inTableType
          endif) as tt( TABLE_CATALOG,
        TABLE_SCHEMA,
        TABLE_NAME,
        PREFIXSYSOWNED,
        TABLE_TYPE,
        TABLE_GUID,
        DESCRIPTION,
        TABLE_PROPID,
        DATE_CREATED,
        DATE_MODIFIED ) 
      order by 4 asc,1 asc,2 asc,3 asc
  else
    select null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as TABLE_TYPE,
      null as TABLE_GUID,
      null as DESCRIPTION,
      null as TABLE_PROPID,
      null as DATE_CREATED,
      null as DATE_MODIFIED
  end if
end
