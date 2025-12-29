-- PF: UNKNOWN_SCHEMA.sp_jdbc_columns
-- proc_id: 331
-- generated_at: 2025-12-29T13:53:28.789Z

create procedure dbo.sp_jdbc_columns( 
  @table_name varchar(128),
  @table_owner varchar(128)= null,
  @table_qualifier varchar(128)= null,
  @column_name varchar(128)= null ) 
as
declare @tableid integer
declare @columnid integer
declare @id integer
if @column_name is null select @column_name = '%'
if @table_name is null select @table_name = '%'
if @table_owner is null select @table_owner = '%'
select TABLE_CAT=dbo.sp_jconnect_trimit(db_name()),
  TABLE_SCHEM=dbo.sp_jconnect_trimit(USER_NAME(creator)),
  TABLE_NAME=dbo.sp_jconnect_trimit(table_name),
  COLUMN_NAME=dbo.sp_jconnect_trimit(column_name),
  DATA_TYPE=(select DATA_TYPE from dbo.spt_jdatatype_info
    where LOCAL_TYPE_NAME
     = (select if domain_name = 'integer' then
        'int' else domain_name endif)),
  TYPE_NAME=dbo.sp_jconnect_trimit(
  if((user_type is not null) and(user_type > 108)) then
    (select type_name from SYS.SYSUSERTYPE
      where type_id = c.user_type)
  else(select TYPE_NAME from dbo.spt_jdatatype_info
      where LOCAL_TYPE_NAME
       = (select if domain_name = 'integer' then 'int'
        else domain_name
        endif))
  endif),COLUMN_SIZE=(select if DATA_TYPE in( 12,3,2,1,-2,-3 ) then width
    else(select typelength from dbo.spt_jdatatype_info
        where LOCAL_TYPE_NAME
         = (select if domain_name = 'integer' then
            'int' else domain_name endif))
    endif),BUFFER_LENGTH=(select if DATA_TYPE in( 12,3,2,1,-2,-3 ) then width
    else(select typelength from dbo.spt_jdatatype_info
        where LOCAL_TYPE_NAME
         = (select if domain_name = 'integer' then
            'int' else domain_name endif))
    endif),DECIMAL_DIGITS=isnull(scale,0),
  NUM_PREC_RADIX=(select NUM_PREC_RADIX from dbo.spt_jdatatype_info
    where LOCAL_TYPE_NAME
     = (select if domain_name = 'integer' then
        'int' else domain_name endif)),
  NULLABLE=(select if nulls = 'N' then 0 else 1 endif),
  REMARKS=c.remarks,
  COLUMN_DEF=c."default",
  SQL_DATA_TYPE=(select SQL_DATA_TYPE from dbo.spt_jdatatype_info
    where LOCAL_TYPE_NAME
     = (select if domain_name = 'integer' then
        'int' else domain_name endif)),
  SQL_DATETIME_SUB=(select SQL_DATETIME_SUB from dbo.spt_jdatatype_info
    where LOCAL_TYPE_NAME
     = (select if domain_name = 'integer' then
        'int' else domain_name endif)),
  CHAR_OCTET_LENGTH=(select if DATA_TYPE in( 12,1,-1 ) then
      width else 0 endif),
  ORDINAL_POSITION=column_id,
  IS_NULLABLE=(select if nulls = 'N' then 'NO' else 'YES' endif),
  SCOPE_CATLOG=null,
  SCOPE_SCHEMA=null,
  SCOPE_TABLE=null,
  SOURCE_DATA_TYPE=null,
  IS_AUTOINCREMENT=(select if "default" = 'autoincrement' then 'YES' else 'NO' endif)
  from SYS.SYSCOLUMN as c join SYS.SYSTABLE as t,SYS.SYSDOMAIN join SYS.SYSCOLUMN as c
  where t.table_name like @table_name escape '\\'
  and USER_NAME(creator) like @table_owner escape '\\'
  and c.column_name like @column_name escape '\\'
  order by TABLE_SCHEM asc,TABLE_NAME asc,ORDINAL_POSITION asc
