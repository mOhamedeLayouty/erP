-- PF: UNKNOWN_SCHEMA.sp_jdbc_tables
-- proc_id: 330
-- generated_at: 2025-12-29T13:53:28.788Z

create procedure dbo.sp_jdbc_tables( 
  @table_name varchar(128)= null,
  @table_owner varchar(128)= null,
  @table_qualifier varchar(128)= null,
  @table_type varchar(64)= null ) as
declare @id integer
declare @searchstr varchar(10)
declare @searchstr0 varchar(10)
declare @searchstr1 varchar(10)
declare @searchstr2 varchar(10)
declare @table_owner0 varchar(7)
if @table_name is null select @table_name = '%'
if @table_owner is null select @table_owner = '%'
if(patindex('%system%',lcase(@table_type)) > 0)
  select @searchstr = 'TABLE'
else
  select @searchstr = ''
if((patindex('%table%',lcase(@table_type)) > 0)
  or(patindex('%base%',lcase(@table_type)) > 0))
  select @searchstr0 = 'TABLE'
else
  select @searchstr0 = ''
if(patindex('%view%',lcase(@table_type)) > 0)
  select @searchstr1 = 'VIEW'
else
  select @searchstr1 = ''
if(patindex('%temp%',lcase(@table_type)) > 0)
  select @searchstr2 = '%TEMP%'
else
  select @searchstr2 = ''
if @table_type is null
  begin
    select @searchstr = '%'
    select @searchstr0 = '%'
    select @searchstr1 = '%'
    select @searchstr2 = '%'
  end
if((@searchstr = '') and(@searchstr0 = '') and(@searchstr1 = '')
  and(@searchstr2 = '') and(@table_type is not null))
  begin
    raiserror 99998 'Valid table types: TABLE, BASE, SYSTEM, VIEW, GLOBAL TEMPORARY or null'
    return(3)
  end
begin transaction
delete from jdbc_tablehelp
insert into jdbc_tablehelp
  select db_name(),user_name(st.creator),st.table_name,
    if table_type = 'VIEW' then
      if user_name(creator) = 'SYS' or(user_name(creator) = 'dbo' and table_name
       = any(select name from EXCLUDEOBJECT)) then 'SYSTEM VIEW' else 'VIEW' endif
    else
      if table_type = 'BASE' then
        if user_name(creator) = 'SYS' or(user_name(creator) = 'rs_systabgroup') or(user_name(creator) = 'dbo' and table_name
         = any(select name from EXCLUDEOBJECT)) then 'SYSTEM TABLE' else 'TABLE' endif
      else
        if table_type = 'GBL TEMP' then 'GLOBAL TEMPORARY'
        else 'LOCAL TEMPORARY'
        endif
      endif
    endif,substr(REMARKS,1,128)
    from SYS.SYSTABLE as st
if(@searchstr = '')
  begin
    delete from jdbc_tablehelp where TABLE_TYPE = 'SYSTEM TABLE'
  end
if(@searchstr0 = '')
  begin
    delete from jdbc_tablehelp where TABLE_TYPE = 'TABLE'
  end
if(@searchstr1 = '')
  begin
    delete from jdbc_tablehelp where TABLE_TYPE like '%VIEW'
  end
if(@searchstr2 = '')
  begin
    delete from jdbc_tablehelp where TABLE_TYPE like '%TEMPORARY'
  end
if(@table_name <> '%')
  begin
    delete from jdbc_tablehelp where lcase(TABLE_NAME) not like lcase(@table_name) escape '\\'
  end
if(@table_owner <> '%')
  begin
    delete from jdbc_tablehelp where lcase(TABLE_SCHEM) not like lcase(@table_owner) escape '\\'
  end
select TABLE_CAT=dbo.sp_jconnect_trimit(TABLE_CAT),
  TABLE_SCHEM=dbo.sp_jconnect_trimit(TABLE_SCHEM),
  TABLE_NAME=dbo.sp_jconnect_trimit(TABLE_NAME),
  TABLE_TYPE=dbo.sp_jconnect_trimit(TABLE_TYPE),
  REMARKS=dbo.sp_jconnect_trimit(REMARKS)
  from jdbc_tablehelp
  order by TABLE_TYPE asc,TABLE_SCHEM asc,TABLE_NAME asc
commit transaction
delete from jdbc_tablehelp
