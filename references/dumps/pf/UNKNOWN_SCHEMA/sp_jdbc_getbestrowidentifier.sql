-- PF: UNKNOWN_SCHEMA.sp_jdbc_getbestrowidentifier
-- proc_id: 345
-- generated_at: 2025-12-29T13:53:28.792Z

create procedure dbo.sp_jdbc_getbestrowidentifier( 
  @table_qualifier varchar(128)= null,
  @table_owner varchar(128)= null,
  @table_name varchar(128),
  @scope integer,
  @nullable smallint ) 
as
declare @nulls char(1)
declare @id integer
if(@table_owner is null) select @table_owner = '%'
else
  begin
    if(locate(@table_owner,'%') > 0)
      begin
        raiserror 17208
          'Wildcards are not allowed here. Please change value of TABLE_SCHEM'
        return(1)
      end
  end
if(@table_name is null)
  begin
    raiserror 17208 'Null is not allowed for parameter TABLE NAME '
    return(1)
  end
execute dbo.sp_jdbc_escapeliteralforlike @table_name
if(select count() from dbo.sysobjects
    where user_name(uid) like @table_owner escape '\\'
    and name like @table_name escape '\\') = 0
  begin
    raiserror 17208
      'There is no object with the specified owner/name combination'
    return
  end
if(@nullable = 0)
  select @nulls = 'N'
else
  select @nulls = 'Y'
select SCOPE=0,
  COLUMN_NAME=dbo.sp_jconnect_trimit(cname),
  DATA_TYPE=(select DATA_TYPE from dbo.spt_jdatatype_info
    where TYPE_NAME = coltype),
  TYPE_NAME=dbo.sp_jconnect_trimit(coltype),
  COLUMN_SIZE=length,
  BUFFER_LENGTH=length,
  DECIMAL_DIGITS=syslength,
  PSEUDO_COLUMN=1
  from SYS.SYSCOLUMNS
  where tname like @table_name escape '\\'
  and in_primary_key = 'Y' and nulls = @nulls
  and creator like @table_owner escape '\\'
  order by SCOPE asc
