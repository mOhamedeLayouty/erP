-- PF: UNKNOWN_SCHEMA.sa_oledb_procedures
-- proc_id: 296
-- generated_at: 2025-12-29T13:53:28.779Z

create procedure dbo.sa_oledb_procedures( 
  in inProcedureCatalog char(128) default '',
  in inProcedureSchema char(128) default '',
  in inProcedureName char(128) default '',
  in inProcedureType smallint default 1 ) 
result( 
  PROCEDURE_CATALOG char(128),
  PROCEDURE_SCHEMA char(128),
  PROCEDURE_NAME char(128),
  PROCEDURE_TYPE smallint,
  PROCEDURE_DEFINITION varchar(16384),
  DESCRIPTION varchar(254),
  DATE_CREATED timestamp,
  DATE_MODIFIED timestamp ) dynamic result sets 1
on exception resume
begin
  if inProcedureCatalog = db_name() or inProcedureCatalog = '' then
    select db_name() as PROCEDURE_CATALOG,
      user_name as PROCEDURE_SCHEMA,
      proc_name as PROCEDURE_NAME,
      cast(coalesce(
      (if(select max(PARM_TYPE) from SYS.SYSPROCPARM
        where proc_id = SYS.SYSPROCEDURE.proc_id) = 4 then
        3
      else 2
      endif),
      1) as smallint) as PROCEDURE_TYPE,
      proc_defn as PROCEDURE_DEFINITION,
      cast(SYSPROCEDURE.remarks as varchar(254)) as DESCRIPTION,
      cast(null as timestamp) as DATE_CREATED,
      cast(null as timestamp) as DATE_MODIFIED
      from SYS.SYSPROCEDURE
        join SYS.SYSUSERPERMS
      where user_name
       = if inProcedureSchema = '' then
        if inProcedureName = '' then user_name
        else dbo.sa_oledb_getowner('procedure',inProcedureName)
        endif
      else inProcedureSchema
      endif
      and proc_name
       = if inProcedureName = '' then proc_name
      else inProcedureName
      endif
      order by 1 asc,2 asc,3 asc
  else
    select null as PROCEDURE_CATALOG,
      null as PROCEDURE_SCHEMA,
      null as PROCEDURE_NAME,
      null as PROCEDURE_TYPE,
      null as PROCEDURE_DEFINITION,
      null as DESCRIPTION,
      null as DATE_CREATED,
      null as DATE_MODIFIED
  end if
end
