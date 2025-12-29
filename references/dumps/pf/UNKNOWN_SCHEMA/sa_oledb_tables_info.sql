-- PF: UNKNOWN_SCHEMA.sa_oledb_tables_info
-- proc_id: 303
-- generated_at: 2025-12-29T13:53:28.781Z

create procedure dbo.sa_oledb_tables_info( 
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
  BOOKMARKS bit,
  BOOKMARK_TYPE integer,
  BOOKMARK_DATATYPE unsigned smallint,
  BOOKMARK_MAXIMUM_LENGTH unsigned integer,
  BOOKMARK_INFORMATION unsigned integer,
  TABLE_VERSION bigint,
  CARDINALITY unsigned bigint,
  DESCRIPTION varchar(254),
  TABLE_PROPID unsigned integer ) dynamic result sets 1
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
      BOOKMARKS,
      BOOKMARK_TYPE,
      BOOKMARK_DATATYPE,
      BOOKMARK_MAXIMUM_LENGTH,
      BOOKMARK_INFORMATION,
      TABLE_VERSION,
      CARDINALITY,
      DESCRIPTION,
      TABLE_PROPID
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
          cast(1 as bit) as BOOKMARKS,
          cast(1 as integer) as BOOKMARK_TYPE,
          cast(19 as unsigned smallint) as BOOKMARK_DATATYPE,
          cast(4 as unsigned integer) as BOOKMARK_MAXIMUM_LENGTH,
          cast(0 as unsigned integer) as BOOKMARK_INFORMATION,
          cast(null as bigint) as TABLE_VERSION,
          cast(count as unsigned bigint) as CARDINALITY,
          cast(SYSTABLE.remarks as varchar(254)) as DESCRIPTION,
          cast(null as integer) as TABLE_PROPID
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
        BOOKMARKS,
        BOOKMARK_TYPE,
        BOOKMARK_DATATYPE,
        BOOKMARK_MAXIMUM_LENGTH,
        BOOKMARK_INFORMATION,
        TABLE_VERSION,
        CARDINALITY,
        DESCRIPTION,
        TABLE_PROPID ) 
      order by 4 asc,1 asc,2 asc,3 asc
  else
    select null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as TABLE_TYPE,
      null as TABLE_GUID,
      null as BOOKMARKS,
      null as BOOKMARK_TYPE,
      null as BOOKMARK_DATATYPE,
      null as BOOKMARK_MAXIMUM_LENGTH,
      null as BOOKMARK_INFORMATION,
      null as TABLE_VERSION,
      null as CARDINALITY,
      null as DESCRIPTION,
      null as TABLE_PROPID
  end if
end
