-- PF: UNKNOWN_SCHEMA.sa_oledb_procedure_parameters
-- proc_id: 295
-- generated_at: 2025-12-29T13:53:28.778Z

create procedure dbo.sa_oledb_procedure_parameters( 
  in inProcedureCatalog char(128) default '',
  in inProcedureSchema char(128) default '',
  in inProcedureName char(128) default '',
  in inParameterName char(128) default '' ) 
result( 
  PROCEDURE_CATALOG char(128),
  PROCEDURE_SCHEMA char(128),
  PROCEDURE_NAME char(128),
  PARAMETER_NAME char(128),
  ORDINAL_POSITION unsigned smallint,
  PARAMETER_TYPE unsigned smallint,
  PARAMETER_HASDEFAULT bit,
  PARAMETER_DEFAULT char(128),
  IS_NULLABLE bit,
  DATA_TYPE unsigned smallint,
  CHARACTER_MAXIMUM_LENGTH unsigned integer,
  CHARACTER_OCTET_LENGTH unsigned integer,
  NUMERIC_PRECISION unsigned smallint,
  NUMERIC_SCALE smallint,
  DESCRIPTION varchar(254),
  TYPE_NAME char(40),
  LOCAL_TYPE_NAME char(40) ) dynamic result sets 1
on exception resume
begin
  if inProcedureCatalog = db_name() or inProcedureCatalog = '' then
    select db_name() as PROCEDURE_CATALOG,
      user_name as PROCEDURE_SCHEMA,
      proc_name as PROCEDURE_NAME,
      parm_name as PARAMETER_NAME,
      cast(if parm_type = 4 then 0
      else isnull((select SYSPROCPARM.parm_id-1
          from SYSPROCPARM as spp2
          where spp2.proc_id = SYSPROCPARM.proc_id
          and spp2.parm_type = 4),SYSPROCPARM.parm_id)
      endif as integer) as ORDINAL_POSITION,
      cast(if parm_type = 4 then
        4
      else if parm_mode_in = 'Y' then
          if parm_mode_out = 'Y' then
            2
          else 1
          endif
        else 3
        endif
      endif as unsigned integer) as PARAMETER_TYPE,
      cast(if "default" is not null then 1 else 0 endif as bit) as PARAMETER_HASDEFAULT,
      "default" as PARAMETER_DEFAULT,
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
      cast(null as varchar(254)) as DESCRIPTION,
      domain_name as TYPE_NAME,
      cast(null as char(128)) as LOCAL_TYPE_NAME
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
       = if inParameterName = '' then
        parm_name
      else inParameterName
      endif
      and parm_type <> 1
      order by 1 asc,2 asc,3 asc,5 asc
  else
    select null as PROCEDURE_CATALOG,
      null as PROCEDURE_SCHEMA,
      null as PROCEDURE_NAME,
      null as PARAMETER_NAME,
      null as ORDINAL_POSITION,
      null as PARAMETER_TYPE,
      null as PARAMETER_HASDEFAULT,
      null as PARAMETER_DEFAULT,
      null as IS_NULLABLE,
      null as DATA_TYPE,
      null as CHARACTER_MAXIMUM_LENGTH,
      null as CHARACTER_OCTET_LENGTH,
      null as NUMERIC_PRECISION,
      null as NUMERIC_SCALE,
      null as DESCRIPTION,
      null as TYPE_NAME,
      null as LOCAL_TYPE_NAME
  end if
end
