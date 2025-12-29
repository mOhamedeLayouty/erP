-- PF: UNKNOWN_SCHEMA.sp_jdbc_getcrossreferences
-- proc_id: 336
-- generated_at: 2025-12-29T13:53:28.790Z

create procedure dbo.sp_jdbc_getcrossreferences( 
  @pktable_qualifier varchar(128)= null,
  @pktable_owner varchar(128)= null,
  @pktable_name varchar(128)= null,
  @fktable_qualifier varchar(128)= null,
  @fktable_owner varchar(128)= null,
  @fktable_name varchar(128)= null ) as
if(@pktable_name is null or @fktable_name is null)
  begin
    raiserror 17208 'Primary Key table name and Foreign Key table name must be given'
    return(1)
  end
if(@pktable_name is null)
  begin
    select @pktable_name = '%'
  end
else
  begin
    execute sp_jdbc_escapeliteralforlike @pktable_name
  end
if(@fktable_name is null)
  begin
    select @fktable_name = '%'
  end
else
  begin
    execute sp_jdbc_escapeliteralforlike @fktable_name
  end
if(@pktable_owner is null)
  begin
    select @pktable_owner = '%'
  end
if(@fktable_owner is null)
  begin
    select @fktable_owner = '%'
  end
if(select count() from dbo.sysobjects
    where user_name(uid) like @pktable_owner escape '\\'
    and name like @pktable_name escape '\\') = 0
  begin
    raiserror 17208
      'There is no primary key object with the specified owner/name combination'
    return(1)
  end
if(select count() from dbo.sysobjects
    where user_name(uid) like @fktable_owner escape '\\'
    and name like @fktable_name escape '\\') = 0
  begin
    raiserror 17208
      'There is no foreign  key object with the specified owner/name combination'
    return(1)
  end
begin transaction
execute dbo.sp_jdbc_fkeys @pktable_name,@pktable_owner,@pktable_qualifier,
@fktable_name,@fktable_owner,@fktable_qualifier
select * from jdbc_helpkeys
  where FKTABLE_NAME like @fktable_name escape '\\'
  and PKTABLE_NAME like @pktable_name escape '\\'
  order by FKTABLE_CAT asc,FKTABLE_SCHEM asc,FKTABLE_NAME asc,KEY_SEQ asc
commit transaction
delete from dbo.jdbc_helpkeys
