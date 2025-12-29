-- PF: UNKNOWN_SCHEMA.sp_jdbc_getfunctioncolumns
-- proc_id: 340
-- generated_at: 2025-12-29T13:53:28.791Z

create procedure dbo.sp_jdbc_getfunctioncolumns( 
  @fn_qualifier varchar(128)= null,
  @fn_owner varchar(128)= null,
  @fn_name varchar(128)= null,
  @column_name varchar(128)= null ) 
as
begin transaction
delete from dbo.jdbc_functioncolumns
if @fn_owner is null select @fn_owner = '%'
if @fn_name is null select @fn_name = '%'
if @column_name is null select @column_name = '%'
insert into dbo.jdbc_functioncolumns
  ( FUNCTION_CAT,FUNCTION_SCHEM,FUNCTION_NAME,COLUMN_NAME,
  COLUMN_TYPE,DATA_TYPE,TYPE_NAME,"PRECISION",LENGTH,SCALE,
  RADIX,NULLABLE,REMARKS,CHAR_OCTET_LENGTH,ORDINAL_POSITION,
  IS_NULLABLE,SPECIFIC_NAME,colid ) 
  select FUNCTION_CAT=dbo.sp_jconnect_trimit(db_name()),
    FUNCTION_SCHEM=dbo.sp_jconnect_trimit(user_name(creator)),
    FUNCTION_NAME=dbo.sp_jconnect_trimit(proc_name),
    COLUMN_NAME=dbo.sp_jconnect_trimit(parm_name),
    COLUMN_TYPE=(select(if parm_type = 0 and parm_mode_in = 'Y' and parm_mode_out = 'N' then 1
      else if parm_type = 0 and parm_mode_in = 'Y' and parm_mode_out = 'Y' then 2
        else if parm_type = 1 and parm_mode_in = 'N' and parm_mode_out = 'Y' then 3
          else if parm_type = 0 and parm_mode_in = 'N' and parm_mode_out = 'Y' then 4
            else 0
            endif
          endif
        endif
      endif)),DATA_TYPE=(select DATA_TYPE from dbo.spt_jdatatype_info where LOCAL_TYPE_NAME
       = (select if domain_name = 'integer' then 'int' else domain_name endif)),
    TYPE_NAME=(select if sd.domain_name = 'integer' then 'int' else dbo.sp_jconnect_trimit(sd.domain_name) endif),
    'PRECISION'=(select if DATA_TYPE in( 12,3,2,1,-2,-3 ) then width
      else(select typelength from dbo.spt_jdatatype_info where LOCAL_TYPE_NAME
           = (select if domain_name = 'integer' then 'int' else domain_name endif))
      endif),LENGTH=width,
    SCALE=scale,
    RADIX=0,
    NULLABLE=2,
    REMARKS=null,
    CHAR_OCTET_LENGTH=(select if DATA_TYPE in( 12,1,-1 ) then width else 0 endif),
    ORDINAL_POSITION=(parm_id-1),
    IS_NULLABLE='',
    SPECIFIC_NAME=dbo.sp_jconnect_trimit(proc_name),
    colid=parm_id
    from SYS.SYSPROCEDURE key join SYS.SYSPROCPARM,dbo.spt_jdatatype_info,dbo.SYSTYPES as st
    where proc_name like @fn_name escape '\\'
    and parm_name like @column_name escape '\\'
    and user_name(creator) like @fn_owner escape '\\'
    and sd.domain_id = SYSPROCPARM
    and parm_name <> proc_name
    and(select count() from SYSPROCPARM as parms where parms.proc_id = p.proc_id
      and dbo.sp_jconnect_trimit(parm_name) = dbo.sp_jconnect_trimit(proc_name)) <> 0
insert into dbo.jdbc_functioncolumns
  ( FUNCTION_CAT,FUNCTION_SCHEM,FUNCTION_NAME,COLUMN_NAME,
  COLUMN_TYPE,DATA_TYPE,TYPE_NAME,"PRECISION",LENGTH,SCALE,
  RADIX,NULLABLE,REMARKS,CHAR_OCTET_LENGTH,ORDINAL_POSITION,
  IS_NULLABLE,SPECIFIC_NAME,colid ) 
  select distinct
    FUNCTION_CAT=dbo.sp_jconnect_trimit(db_name()),
    FUNCTION_SCHEM=dbo.sp_jconnect_trimit(user_name(creator)),
    FUNCTION_NAME=dbo.sp_jconnect_trimit(proc_name),
    COLUMN_NAME='RETURN_VALUE',
    COLUMN_TYPE=5,
    DATA_TYPE=dbo.spt_jdatatype_info.DATA_TYPE,
    TYPE_NAME=dbo.spt_jdatatype_info.TYPE_NAME,
    'PRECISION'=st.prec,
    LENGTH=4,
    SCALE=(select(if st.scale is null then 0 else st.scale endif)),
    RADIX=0,
    NULLABLE=0,
    REMARKS='functionColumnReturn',
    CHAR_OCTET_LENGTH=0,
    ORDINAL_POSITION=0,
    IS_NULLABLE='NO',
    SPECIFIC_NAME=dbo.sp_jconnect_trimit(proc_name),
    colid=0
    from SYS.SYSPROCEDURE key join SYS.SYSPROCPARM,dbo.spt_jdatatype_info,dbo.SYSTYPES as st
    where ss_dtype = 56
    and dbo.spt_jdatatype_info.TYPE_NAME = 'int'
    and st.type = ss_dtype
    and proc_name like @fn_name escape '\\'
    and 'RETURN_VALUE' like @column_name escape '\\'
    and user_name(creator) like @fn_owner escape '\\'
    and parm_type <> 4
    and(select count() from SYSPROCPARM as parms where parms.proc_id = p.proc_id
      and dbo.sp_jconnect_trimit(parm_name) = dbo.sp_jconnect_trimit(proc_name)) <> 0
select FUNCTION_CAT,FUNCTION_SCHEM,FUNCTION_NAME,COLUMN_NAME,COLUMN_TYPE,DATA_TYPE,
  TYPE_NAME,"PRECISION",LENGTH,SCALE,RADIX,NULLABLE,REMARKS,CHAR_OCTET_LENGTH,
  ORDINAL_POSITION,IS_NULLABLE,SPECIFIC_NAME
  from dbo.jdbc_functioncolumns
  order by FUNCTION_CAT asc,FUNCTION_SCHEM asc,FUNCTION_NAME asc,SPECIFIC_NAME asc,colid asc
commit transaction
delete from dbo.jdbc_functioncolumns
