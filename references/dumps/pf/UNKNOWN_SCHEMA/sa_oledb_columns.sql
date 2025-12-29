-- PF: UNKNOWN_SCHEMA.sa_oledb_columns
-- proc_id: 290
-- generated_at: 2025-12-29T13:53:28.777Z

create procedure dbo.sa_oledb_columns( 
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inTableName char(128) default '',
  in inColumnName char(128) default '' ) 
result( 
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  COLUMN_NAME char(128),
  COLUMN_GUID uniqueidentifier,
  COLUMN_PROPID unsigned integer,
  ORDINAL_POSITION unsigned integer,
  COLUMN_HASDEFAULT bit,
  COLUMN_DEFAULT varchar(254),
  COLUMN_FLAGS unsigned integer,
  IS_NULLABLE bit,
  DATA_TYPE unsigned smallint,
  TYPE_GUID uniqueidentifier,
  CHARACTER_MAXIMUM_LENGTH unsigned integer,
  CHARACTER_OCTET_LENGTH unsigned integer,
  NUMERIC_PRECISION unsigned smallint,
  NUMERIC_SCALE smallint,
  DATETIME_PRECISION unsigned integer,
  CHARACTER_SET_CATALOG char(128),
  CHARACTER_SET_SCHEMA char(128),
  CHARACTER_SET_NAME char(128),
  COLLATION_CATALOG char(128),
  COLLATION_SCHEMA char(128),
  COLLATION_NAME char(128),
  DOMAIN_CATALOG char(128),
  DOMAIN_SCHEMA char(128),
  DOMAIN_NAME char(128),
  DESCRIPTION varchar(254) ) dynamic result sets 1
on exception resume
begin
  if inTableCatalog = db_name() or inTableCatalog = '' then
    select db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      COLUMN_NAME,
      cast(null as uniqueidentifier) as COLUMN_GUID,
      cast(null as unsigned integer) as COLUMN_PROPID,
      cast(SYSCOLUMN.column_id as unsigned integer) as ORDINAL_POSITION,
      cast(if SYSCOLUMN."default" is null then 0 else 1 endif as bit) as COLUMN_HASDEFAULT,
      cast(if SYSCOLUMN."default" is null then 'NULL' else SYSCOLUMN."default" endif as varchar(254)) as COLUMN_DEFAULT,
      cast((if nulls = 'Y' then 64+32 else 0 endif)
      |(if SYSDOMAIN.domain_name like 'long%' then 128 else 0 endif)
      |(if SYSDOMAIN.domain_name like 'st_%' then 128 else 0 endif)
      |(if SYSDOMAIN.domain_name = 'xml' then 128 else 0 endif)
      |(if SYSDOMAIN.domain_name like '%int%' then 16 else 0 endif)
      |(if SYSDOMAIN.domain_name like '%time%' then 16 else 0 endif)
      |(if SYSDOMAIN.domain_name in( 
      'float','double','bit','uniqueidentifier','numeric','decimal','date' ) then 16 else 0 endif)
      |4 as unsigned integer) as COLUMN_FLAGS,
      cast(if nulls = 'Y' then 1 else 0 endif as bit) as IS_NULLABLE,
      cast(case SYSDOMAIN.domain_name
      when 'smallint' then 2
      when 'integer' then 3
      when 'float' then 4
      when 'double' then 5
      when 'bit' then 11
      when 'tinyint' then 17
      when 'unsigned smallint' then 18
      when 'unsigned int' then 19
      when 'bigint' then 20
      when 'unsigned bigint' then 21
      when 'uniqueidentifier' then 72
      when 'binary' then 128
      when 'varbinary' then 128
      when 'long binary' then 128
      when 'varbit' then 129
      when 'long varbit' then 129
      when 'st_geometry' then 129
      when 'char' then 129
      when 'long varchar' then 129
      when 'varchar' then 129
      when 'nchar' then 130
      when 'nvarchar' then 130
      when 'long nvarchar' then 130
      when 'numeric' then 131
      when 'decimal' then 131
      when 'date' then 133
      when 'time' then 145
      when 'timestamp' then 135
      when 'xml' then 129
      when 'timestamp with time zone' then 146
      else 129
      end as unsigned smallint) as DATA_TYPE,
      cast(null as uniqueidentifier) as TYPE_GUID,
      cast(coalesce(
      if SYSDOMAIN.domain_name like 'long%' then 2147483647 endif,
      if SYSDOMAIN.domain_name like 'st_%' then 2147483647 endif,
      if SYSDOMAIN.domain_name = 'xml' then 2147483647 endif,
      if SYSDOMAIN.domain_name = 'uniqueidentifier' then 16 endif,
      if SYSDOMAIN.domain_name = 'bit' then 1 endif,
      if(SYSDOMAIN.domain_name = 'nchar'
      or SYSDOMAIN.domain_name = 'nvarchar') then
        SYSCOLUMN.width
      endif,
      if(SYSDOMAIN.domain_name = 'binary'
      or SYSDOMAIN.domain_name = 'varbinary'
      or SYSDOMAIN.domain_name = 'varbit'
      or SYSDOMAIN.domain_name = 'char'
      or SYSDOMAIN.domain_name = 'varchar') then
        SYSCOLUMN.width
      else null
      endif) as unsigned integer) as CHARACTER_MAXIMUM_LENGTH,
      cast(coalesce(
      if SYSDOMAIN.domain_name like 'long%' then 2147483647 endif,
      if SYSDOMAIN.domain_name like 'st_%' then 2147483647 endif,
      if SYSDOMAIN.domain_name = 'xml' then 2147483647 endif,
      if SYSDOMAIN.domain_name = 'uniqueidentifier' then 16 endif,
      if(SYSDOMAIN.domain_name = 'nchar'
      or SYSDOMAIN.domain_name = 'nvarchar') then
        SYSCOLUMN.width*4
      endif,
      if(SYSDOMAIN.domain_name = 'binary'
      or SYSDOMAIN.domain_name = 'varbinary'
      or SYSDOMAIN.domain_name = 'char'
      or SYSDOMAIN.domain_name = 'varchar') then
        SYSCOLUMN.width
      else null
      endif) as unsigned integer) as CHARACTER_OCTET_LENGTH,
      cast(case SYSDOMAIN.domain_name
      when 'numeric' then SYSCOLUMN.width
      when 'decimal' then SYSCOLUMN.width
      when 'time' then 16
      when 'timestamp with time zone' then 34
      else null
      end as unsigned smallint) as NUMERIC_PRECISION,
      cast(case SYSDOMAIN.domain_name
      when 'numeric' then SYSCOLUMN.scale
      when 'decimal' then SYSCOLUMN.scale
      when 'time' then 7
      when 'timestamp with time zone' then 7
      else null
      end as smallint) as NUMERIC_SCALE,
      cast(if SYSDOMAIN.domain_name = 'date'
      or SYSDOMAIN.domain_name = 'datetime'
      or SYSDOMAIN.domain_name = 'smalldatetime'
      or SYSDOMAIN.domain_name = 'time'
      or SYSDOMAIN.domain_name like 'timestamp%' then
        6
      else null
      endif as unsigned integer) as DATETIME_PRECISION,
      cast(null as char(128)) as CHARACTER_SET_CATALOG,
      cast(null as char(128)) as CHARACTER_SET_SCHEMA,
      cast(null as char(128)) as CHARACTER_SET_NAME,
      cast(null as char(128)) as COLLATION_CATALOG,
      cast(null as char(128)) as COLLATION_SCHEMA,
      cast(null as char(128)) as COLLATION_NAME,
      cast(null as char(128)) as DOMAIN_CATALOG,
      cast(null as char(128)) as DOMAIN_SCHEMA,
      cast(null as char(128)) as DOMAIN_NAME,
      cast(SYSCOLUMN.remarks as varchar(254)) as DESCRIPTION
      from SYS.SYSCOLUMN
        join SYS.SYSTABLE
        join SYS.SYSUSERPERMS
        join SYS.SYSDOMAIN
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
      and COLUMN_NAME
       = if inColumnName = '' then column_name
      else inColumnName
      endif
      order by 1 asc,2 asc,3 asc,SYSCOLUMN.column_id asc
  else
    select null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as COLUMN_NAME,
      null as COLUMN_GUID,
      null as COLUMN_PROPID,
      null as ORDINAL_POSITION,
      null as COLUMN_HASDEFAULT,
      null as COLUMN_DEFAULT,
      null as COLUMN_FLAGS,
      null as IS_NULLABLE,
      null as DATA_TYPE,
      null as TYPE_GUID,
      null as CHARACTER_MAXIMUM_LENGTH,
      null as CHARACTER_OCTET_LENGTH,
      null as NUMERIC_PRECISION,
      null as NUMERIC_SCALE,
      null as DATETIME_PRECISION,
      null as CHARACTER_SET_CATALOG,
      null as CHARACTER_SET_SCHEMA,
      null as CHARACTER_SET_NAME,
      null as COLLATION_CATALOG,
      null as COLLATION_SCHEMA,
      null as COLLATION_NAME,
      null as DOMAIN_CATALOG,
      null as DOMAIN_SCHEMA,
      null as DOMAIN_NAME,
      null as DESCRIPTION
  end if
end
