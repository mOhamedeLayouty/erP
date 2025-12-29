-- PF: UNKNOWN_SCHEMA.sp_jdbc_exportkey
-- proc_id: 334
-- generated_at: 2025-12-29T13:53:28.789Z

create procedure dbo.sp_jdbc_exportkey( 
  @table_qualifier varchar(128)= null,
  @table_owner varchar(128)= null,
  @table_name varchar(128)= null ) 
as
if(@table_owner is null)
  begin
    select @table_owner = '%'
  end
if(@table_name is null)
  begin
    raiserror 17208 'Null is not allowed for parameter TABLE NAME '
    return(1)
  end
begin transaction
execute sp_jdbc_escapeliteralforlike @table_name
if(select count() from sysobjects
    where user_name(uid) like @table_owner escape '\\'
    and name like @table_name escape '\\') = 0
  begin
    raiserror 17208
      'There is no object with the specified owner/name combination'
    return(1)
  end
execute dbo.sp_jdbc_fkeys @table_name,@table_owner,@table_qualifier,
null,null,null
select * from dbo.jdbc_helpkeys
  order by FKTABLE_CAT asc,FKTABLE_SCHEM asc,FKTABLE_NAME asc,KEY_SEQ asc
commit transaction
delete from dbo.jdbc_helpkeys
