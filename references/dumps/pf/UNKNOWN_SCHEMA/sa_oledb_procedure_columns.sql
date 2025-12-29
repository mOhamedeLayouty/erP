-- PF: UNKNOWN_SCHEMA.sa_oledb_procedure_columns
-- proc_id: 294
-- generated_at: 2025-12-29T13:53:28.778Z

create procedure dbo.sa_oledb_procedure_columns( 
  in inProcedureCatalog char(128) default '',
  in inProcedureSchema char(128) default '',
  in inProcedureName char(128) default '',
  in inColumnName char(128) default '' ) 
result( 
  PROCEDURE_CATALOG char(128),
  PROCEDURE_SCHEMA char(128),
  PROCEDURE_NAME char(128),
  COLUMN_NAME char(128),
  COLUMN_GUID uniqueidentifier,
  COLUMN_PROPID unsigned integer,
  ROWSET_NUMBER unsigned integer,
  ORDINAL_POSITION integer,
  IS_NULLABLE bit,
  DATA_TYPE unsigned smallint,
  TYPE_GUID uniqueidentifier,
  CHARACTER_MAXIMUM_LENGTH unsigned integer,
  CHARACTER_OCTET_LENGTH unsigned integer,
  NUMERIC_PRECISION unsigned smallint,
  NUMERIC_SCALE smallint,
  DESCRIPTION varchar(254) ) dynamic result sets 1
on exception resume
begin
  if inProcedureCatalog = db_name() or inProcedureCatalog = '' then
    select db_name() as PROCEDURE_CATALOG,
      user_name as PROCEDURE_SCHEMA,
      proc_name as PROCEDURE_NAME,
      parm_name as COLUMN_NAME,
      cast(null as uniqueidentifier) as COLUMN_GUID,
      cast(null as unsigned integer) as COLUMN_PROPID,
      cast(1 as unsigned integer) as ROWSET_NUMBER,
      cast(parm_id
      -(select min(spp2.parm_id)-1
        from SYSPROCPARM as spp2
        where spp2.proc_id = SYSPROCPARM.proc_id
        and spp2.parm_type = 1) as integer) as ORDINAL_POSITION,
      cast(1 as bit) as IS_NULLABLE,
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
      if SYSDOMAIN.domain_name = 'timestamp with time zone' then 33 endif,
      if SYSDOMAIN.domain_name = 'bit' then 1 endif,
      if(SYSDOMAIN.domain_name = 'nchar'
      or SYSDOMAIN.domain_name = 'nvarchar') then
        SYSPROCPARM.width
      endif,
      if(SYSDOMAIN.domain_name = 'binary'
      or SYSDOMAIN.domain_name = 'varbinary'
      or SYSDOMAIN.domain_name = 'varbit'
      or SYSDOMAIN.domain_name = 'char'
      or SYSDOMAIN.domain_name = 'varchar') then
        SYSPROCPARM.width
      else null
      endif) as unsigned integer) as CHARACTER_MAXIMUM_LENGTH,
      cast(coalesce(
      if SYSDOMAIN.domain_name like 'long%' then 2147483647 endif,
      if SYSDOMAIN.domain_name like 'st_%' then 2147483647 endif,
      if SYSDOMAIN.domain_name = 'xml' then 2147483647 endif,
      if SYSDOMAIN.domain_name = 'uniqueidentifier' then 16 endif,
      if SYSDOMAIN.domain_name = 'timestamp with time zone' then 33 endif,
      if(SYSDOMAIN.domain_name = 'nchar'
      or SYSDOMAIN.domain_name = 'nvarchar') then
        SYSPROCPARM.width*4
      endif,
      if(SYSDOMAIN.domain_name = 'binary'
      or SYSDOMAIN.domain_name = 'varbinary'
      or SYSDOMAIN.domain_name = 'char'
      or SYSDOMAIN.domain_name = 'varchar') then
        SYSPROCPARM.width
      else null
      endif) as unsigned integer) as CHARACTER_OCTET_LENGTH,
      cast(if SYSDOMAIN.domain_name = 'numeric'
      or SYSDOMAIN.domain_name = 'decimal' then
        SYSPROCPARM.width
      else null
      endif as unsigned smallint) as NUMERIC_PRECISION,
      cast(if SYSDOMAIN.domain_name = 'numeric'
      or SYSDOMAIN.domain_name = 'decimal' then
        SYSPROCPARM.scale
      else null
      endif as smallint) as NUMERIC_SCALE,
      cast(null as varchar(254)) as DESCRIPTION
      from SYS.SYSUSERPERMS
        join SYS.SYSPROCEDURE
        join SYS.SYSPROCPARM
        join SYS.SYSDOMAIN
      where user_name
       = if inProcedureSchema = '' then
        if inProcedureName = '' then user_name
        else dbo.sa_oledb_getowner('procedure',inProcedureName)
        endif
      else inProcedureSchema
      endif
      and proc_name
       = if inProcedureName = '' then
        proc_name
      else inProcedureName
      endif
      and parm_name
       = if inColumnName = '' then
        parm_name
      else inColumnName
      endif
      and parm_type = 1
      order by 1 asc,2 asc,3 asc,8 asc
  else
    select null as PROCEDURE_CATALOG,
      null as PROCEDURE_SCHEMA,
      null as PROCEDURE_NAME,
      null as COLUMN_NAME,
      null as COLUMN_GUID,
      null as COLUMN_PROPID,
      null as ROWSET_NUMBER,
      null as ORDINAL_POSITION,
      null as IS_NULLABLE,
      null as DATA_TYPE,
      null as TYPE_GUID,
      null as CHARACTER_MAXIMUM_LENGTH,
      null as CHARACTER_OCTET_LENGTH,
      null as NUMERIC_PRECISION,
      null as NUMERIC_SCALE,
      null as DESCRIPTION
  end if
end
