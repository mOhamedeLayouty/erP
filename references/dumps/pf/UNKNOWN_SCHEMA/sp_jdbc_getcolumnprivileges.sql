-- PF: UNKNOWN_SCHEMA.sp_jdbc_getcolumnprivileges
-- proc_id: 344
-- generated_at: 2025-12-29T13:53:28.792Z

create procedure dbo.sp_jdbc_getcolumnprivileges( 
  @table_qualifier varchar(128)= null,
  @table_owner varchar(128)= null,
  @table_name varchar(128)= null,
  @column_name varchar(128)= null ) 
as
declare @dbname varchar(128)
declare @schem varchar(128)
declare @grantor varchar(128)
declare @grantee varchar(128)
declare @columnname varchar(128)
declare @tableid integer
declare @columnid integer
declare @actual_table_name varchar(128)
if(@table_owner is null)
  begin
    select @table_owner = user_name()
  end
execute dbo.sp_jdbc_escapeliteralforlike @table_owner
if(@table_name is null)
  begin
    raiserror 17208 'Null is not allowed for parameter TABLE NAME '
    return(1)
  end
select @actual_table_name = @table_name
execute dbo.sp_jdbc_escapeliteralforlike @table_name
execute dbo.sp_jdbc_escapeliteralforlike @column_name
if @column_name is null select @column_name = '%'
if(select count() from SYS.SYSCOLUMNS
    where creator like @table_owner escape '\\'
    and tname like @table_name escape '\\'
    and cname like @column_name escape '\\') = 0
  begin
    raiserror 17208
      'There is no object with the specified owner/name combination'
    return(1)
  end
select @tableid = table_id from SYS.SYSTABLE
  where table_name like @table_name escape '\\'
  and user_name(creator) like @table_owner escape '\\'
select @dbname = dbo.sp_jconnect_trimit(db_name())
begin transaction
declare getcolid dynamic scroll cursor for select column_id from SYS.SYSCOLUMN
    where column_name like @column_name escape '\\'
    and table_id = @tableid
open getcolid
fetch next getcolid
  into @columnid
while(@@sqlstatus = 0)
  begin
    select @columnname = column_name from SYS.SYSCOLUMN where column_id = @columnid
      and table_id = @tableid
    select
      @grantor = (select user_name(creator) from SYS.SYSTABLE
        where table_id = @tableid)
    insert into dbo.jdbc_columnprivileges values( db_name(),@grantor,
      @actual_table_name,@columnname,@grantor,@grantor,'SELECT','YES' ) 
    insert into dbo.jdbc_columnprivileges values( db_name(),@grantor,
      @actual_table_name,@columnname,@grantor,@grantor,'UPDATE','YES' ) 
    insert into dbo.jdbc_columnprivileges values( db_name(),@grantor,
      @actual_table_name,@columnname,@grantor,@grantor,'DELETE','YES' ) 
    insert into dbo.jdbc_columnprivileges values( db_name(),@grantor,
      @actual_table_name,@columnname,@grantor,@grantor,'ALTER','YES' ) 
    insert into dbo.jdbc_columnprivileges values( db_name(),@grantor,
      @actual_table_name,@columnname,@grantor,@grantor,'REFERENCE','YES' ) 
    select @schem = @grantor
    select @grantor = user_name from SYS.SYSUSERPERM,SYS.SYSTABLEPERM
      where user_id = SYSTABLEPERM.grantor
      and SYSTABLEPERM.stable_id = @tableid
    select @grantee = user_name from SYS.SYSUSERPERM,SYS.SYSTABLEPERM
      where user_id = SYSTABLEPERM.grantee
      and SYSTABLEPERM.stable_id = @tableid
    insert into dbo.jdbc_columnprivileges
      select @dbname,@schem,@actual_table_name,@columnname,@grantor,@grantee,
        if selectauth = 'Y' or selectauth = 'G' then 'SELECT' else 'null' endif,
        if selectauth = 'G' then 'YES' else 'NO' endif
        from SYS.SYSTABLEPERM where stable_id = @tableid
    insert into dbo.jdbc_columnprivileges
      select @dbname,@schem,@actual_table_name,@columnname,@grantor,@grantee,
        if insertauth = 'Y' or insertauth = 'G' then 'INSERT' else 'null' endif,
        if insertauth = 'G' then 'YES' else 'NO' endif
        from SYS.SYSTABLEPERM where stable_id = @tableid
    insert into dbo.jdbc_columnprivileges
      select @dbname,@schem,@actual_table_name,@columnname,@grantor,@grantee,
        if deleteauth = 'Y' or deleteauth = 'G' then 'DELETE' else 'null' endif,
        if deleteauth = 'G' then 'YES' else 'NO' endif
        from SYS.SYSTABLEPERM where stable_id = @tableid
    insert into dbo.jdbc_columnprivileges
      select @dbname,@schem,@actual_table_name,@columnname,@grantor,@grantee,
        if updateauth = 'Y' or updateauth = 'G' then 'UPDATE' else 'null' endif,
        if updateauth = 'G' then 'YES' else 'NO' endif
        from SYS.SYSTABLEPERM where stable_id = @tableid
    insert into dbo.jdbc_columnprivileges
      select @dbname,@schem,@actual_table_name,@columnname,@grantor,@grantee,
        if alterauth = 'Y' or alterauth = 'G' then 'ALTER' else 'null' endif,
        if alterauth = 'G' then 'YES' else 'NO' endif
        from SYS.SYSTABLEPERM where stable_id = @tableid
    insert into dbo.jdbc_columnprivileges
      select @dbname,@schem,@actual_table_name,@columnname,@grantor,@grantee,
        if referenceauth = 'Y' or referenceauth = 'G' then 'REFERENCE'
        else 'null'
        endif,if referenceauth = 'G' then 'YES' else 'NO' endif
        from SYS.SYSTABLEPERM where stable_id = @tableid
    if(select count() from SYSCOLPERM where table_id = @tableid) > 0
      begin
        update dbo.jdbc_columnprivileges set PRIVILEGE = 'UPDATE'
          where SYS.SYSCOLPERM.column_id = @columnid
        if(select is_grantable from SYS.SYSCOLPERM
            where table_id = @tableid and column_id = @columnid) = 'Y'
          begin
            update dbo.jdbc_columnprivileges set IS_GRANTABLE = 'YES'
              where PRIVILEGE = 'UPDATE'
          end
      end
    fetch next getcolid
      into @columnid
  end
close getcolid
select distinct * from dbo.jdbc_columnprivileges where PRIVILEGE <> 'null'
  and TABLE_SCHEM like @table_owner escape '\\'
  and COLUMN_NAME like @column_name escape '\\'
  order by COLUMN_NAME asc,PRIVILEGE asc
commit transaction
delete from dbo.jdbc_columnprivileges
