-- PF: UNKNOWN_SCHEMA.sp_jdbc_getprocedurecolumns
-- proc_id: 339
-- generated_at: 2025-12-29T13:53:28.791Z

create procedure dbo.sp_jdbc_getprocedurecolumns( 
  @sp_qualifier varchar(128)= null,
  @sp_owner varchar(128)= null,
  @sp_name varchar(128)= null,
  @column_name varchar(128)= null,
  @parammetadata integer= 0,
  @paramcolids varchar(1000)= null,
  @paramnames varchar(1000)= null ) 
as
begin transaction
delete from dbo.jdbc_procedurecolumns
if @sp_owner is null select @sp_owner = '%'
if @sp_name is null select @sp_name = '%'
if @column_name is null select @column_name = '%'
insert into dbo.jdbc_procedurecolumns
  ( PROCEDURE_CAT,PROCEDURE_SCHEM,PROCEDURE_NAME,COLUMN_NAME,
  COLUMN_TYPE,DATA_TYPE,TYPE_NAME,"PRECISION",LENGTH,SCALE,
  RADIX,NULLABLE,REMARKS,COLUMN_DEF,SQL_DATA_TYPE,SQL_DATETIME_SUB,
  CHAR_OCTET_LENGTH,ORDINAL_POSITION,IS_NULLABLE,SPECIFIC_NAME,colid ) 
  select PROCEDURE_CAT=dbo.sp_jconnect_trimit(db_name()),
    PROCEDURE_SCHEM=dbo.sp_jconnect_trimit(user_name(creator)),
    PROCEDURE_NAME=dbo.sp_jconnect_trimit(proc_name),
    COLUMN_NAME=dbo.sp_jconnect_trimit(parm_name),
    COLUMN_TYPE=(select(if parm_type = 0 and parm_mode_in = 'Y' and parm_mode_out = 'N' then 1
      else if parm_type = 0 and parm_mode_in = 'Y' and parm_mode_out = 'Y' then 2
        else if parm_type = 1 and parm_mode_in = 'N' and parm_mode_out = 'Y' then 3
          else if parm_type = 0 and parm_mode_in = 'N' and parm_mode_out = 'Y' then 4
            else 0
            endif
          endif
        endif
      endif)),DATA_TYPE=(select DATA_TYPE from dbo.spt_jdatatype_info
      where LOCAL_TYPE_NAME
       = (select if domain_name = 'integer' then 'int'
        else domain_name
        endif)),TYPE_NAME=(select if sd.domain_name = 'integer' then 'int'
      else dbo.sp_jconnect_trimit(sd.domain_name)
      endif),
    'PRECISION'=(select if DATA_TYPE in( 12,3,2,1,-2,-3 ) then width
      else(select typelength from dbo.spt_jdatatype_info
          where LOCAL_TYPE_NAME
           = (select if domain_name = 'integer' then 'int'
            else domain_name
            endif))
      endif),LENGTH=width,
    SCALE=scale,
    RADIX=0,
    NULLABLE=2,
    REMARKS=null,
    COLUMN_DEF=null,
    SQL_DATA_TYPE=0,
    SQL_DATETIME_SUB=0,
    CHAR_OCTET_LENGTH=(select if DATA_TYPE in( 12,1,-1 ) then width else 0 endif),
    ORDINAL_POSITION=parm_id,
    IS_NULLABLE='',
    SPECIFIC_NAME=dbo.sp_jconnect_trimit(proc_name),
    colid=parm_id
    from SYS.SYSPROCEDURE as p join SYS.SYSPROCPARM as pp on(p.proc_id = pp.proc_id),SYS.SYSDOMAIN as sd
    where proc_name like @sp_name escape '\\'
    and parm_name like @column_name escape '\\'
    and user_name(creator) like @sp_owner escape '\\'
    and sd.domain_id = pp.domain_id
insert into dbo.jdbc_procedurecolumns
  ( PROCEDURE_CAT,PROCEDURE_SCHEM,PROCEDURE_NAME,COLUMN_NAME,
  COLUMN_TYPE,DATA_TYPE,TYPE_NAME,"PRECISION",LENGTH,SCALE,
  RADIX,NULLABLE,REMARKS,COLUMN_DEF,SQL_DATA_TYPE,SQL_DATETIME_SUB,
  CHAR_OCTET_LENGTH,ORDINAL_POSITION,IS_NULLABLE,SPECIFIC_NAME,colid ) 
  select distinct
    PROCEDURE_CAT=dbo.sp_jconnect_trimit(db_name()),
    PROCEDURE_SCHEM=dbo.sp_jconnect_trimit(user_name(creator)),
    PROCEDURE_NAME=dbo.sp_jconnect_trimit(proc_name),
    COLUMN_NAME='RETURN_VALUE',
    COLUMN_TYPE=5,
    DATA_TYPE=dbo.spt_jdatatype_info.DATA_TYPE,
    TYPE_NAME=dbo.spt_jdatatype_info.TYPE_NAME,
    'PRECISION'=st.prec,
    LENGTH=4,
    SCALE=(select(if st.scale is null then 0
      else st.scale
      endif)),RADIX=0,
    NULLABLE=0,
    REMARKS='procedureColumnReturn',
    COLUMN_DEF=null,
    SQL_DATA_TYPE=0,
    SQL_DATETIME_SUB=0,
    CHAR_OCTET_LENGTH=0,
    ORDINAL_POSITION=0,
    IS_NULLABLE='',
    SPECIFIC_NAME=dbo.sp_jconnect_trimit(proc_name),
    colid=0
    from SYS.SYSPROCEDURE as p join SYS.SYSPROCPARM as pp on(p.proc_id = pp.proc_id),dbo.spt_jdatatype_info,dbo.SYSTYPES as st
    where ss_dtype = 56
    and dbo.spt_jdatatype_info.TYPE_NAME = 'int'
    and st.type = ss_dtype
    and proc_name like @sp_name escape '\\'
    and 'RETURN_VALUE' like @column_name escape '\\'
    and user_name(creator) like @sp_owner escape '\\'
    and parm_type <> 4
select PROCEDURE_CAT,PROCEDURE_SCHEM,PROCEDURE_NAME,COLUMN_NAME,
  COLUMN_TYPE,DATA_TYPE,TYPE_NAME,"PRECISION",LENGTH,SCALE,
  RADIX,NULLABLE,REMARKS,COLUMN_DEF,SQL_DATA_TYPE,SQL_DATETIME_SUB,
  CHAR_OCTET_LENGTH,ORDINAL_POSITION,IS_NULLABLE,SPECIFIC_NAME
  from dbo.jdbc_procedurecolumns
  order by PROCEDURE_CAT asc,PROCEDURE_SCHEM asc,PROCEDURE_NAME asc,SPECIFIC_NAME asc,colid asc
commit transaction
delete from dbo.jdbc_procedurecolumns
