-- PF: UNKNOWN_SCHEMA.sp_jdbc_gettableprivileges
-- proc_id: 343
-- generated_at: 2025-12-29T13:53:28.792Z

create procedure dbo.sp_jdbc_gettableprivileges( 
  @table_qualifier varchar(128)= null,
  @table_owner varchar(128)= null,
  @table_name varchar(128)= null ) 
as
declare @dbname varchar(128),@schem integer,@tablename varchar(128)
declare @grantor integer,@grantee integer,@selectauth varchar(1)
declare @insertauth varchar(1),@deleteauth varchar(1),@updateauth varchar(1)
declare @alterauth varchar(1),@referenceauth varchar(1)
declare @tableid integer
if @table_owner is null select @table_owner = '%'
if @table_name is null select @table_name = '%'
select @dbname = dbo.sp_jconnect_trimit(db_name())
begin transaction
declare getid dynamic scroll cursor for select creator,creator,table_name
    from SYS.SYSTABLE
    where table_name like @table_name escape '\\'
    and user_name(creator) like @table_owner escape '\\' for read only
open getid
fetch next getid into @schem,@grantor,@tablename
while(@@sqlstatus = 0)
  begin
    insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
      @tablename,user_name(@grantor),user_name(@grantor),'SELECT','YES' ) 
    insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
      @tablename,user_name(@grantor),user_name(@grantor),'UPDATE','YES' ) 
    insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
      @tablename,user_name(@grantor),user_name(@grantor),'DELETE','YES' ) 
    insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
      @tablename,user_name(@grantor),user_name(@grantor),'ALTER','YES' ) 
    insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
      @tablename,user_name(@grantor),user_name(@grantor),'REFERENCE','YES' ) 
    insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
      @tablename,user_name(@grantor),user_name(@grantor),'INSERT','YES' ) 
    fetch next getid into @schem,@grantor,@tablename
  end
close getid
if((select count() from SYSTABLEPERM as perm join SYSTABLE as tab on(perm.stable_id = tab.table_id)
    where table_name like @table_name escape '\\'
    and user_name(creator) like @table_owner escape '\\') > 0)
  begin
    declare getid2 dynamic scroll cursor for select stable_id,creator,grantor,grantee,table_name,selectauth,
        insertauth,deleteauth,updateauth,alterauth,referenceauth
        from SYS.SYSTABLEPERM as perm join SYS.SYSTABLE as tab on(perm.stable_id = tab.table_id)
        where table_name like @table_name escape '\\'
        and user_name(creator) like @table_owner escape '\\' for read only
    open getid2
    fetch next getid2 into @tableid,@schem,@grantor,@grantee,@tablename,@selectauth,
      @insertauth,@deleteauth,@updateauth,@alterauth,
      @referenceauth
    while(@@sqlstatus = 0)
      begin
        insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
          @tablename,user_name(@grantor),user_name(@grantor),'SELECT','YES' ) 
        insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
          @tablename,user_name(@grantor),user_name(@grantor),'UPDATE','YES' ) 
        insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
          @tablename,user_name(@grantor),user_name(@grantor),'DELETE','YES' ) 
        insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
          @tablename,user_name(@grantor),user_name(@grantor),'ALTER','YES' ) 
        insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
          @tablename,user_name(@grantor),user_name(@grantor),'REFERENCE','YES' ) 
        insert into dbo.jdbc_tableprivileges values( db_name(),user_name(@schem),
          @tablename,user_name(@grantor),user_name(@grantor),'INSERT','YES' ) 
        insert into dbo.jdbc_tableprivileges
          select @dbname,user_name(@schem),@tablename,user_name(@grantor),
            user_name(@grantee),
            if @selectauth = 'Y' or @selectauth = 'G' then 'SELECT' else 'null' endif,
            if @selectauth = 'G' then 'YES' else 'NO' endif
        insert into dbo.jdbc_tableprivileges
          select @dbname,user_name(@schem),@tablename,user_name(@grantor),
            user_name(@grantee),
            if @insertauth = 'Y' or @insertauth = 'G' then 'INSERT' else 'null' endif,
            if @insertauth = 'G' then 'YES' else 'NO' endif
        insert into dbo.jdbc_tableprivileges
          select @dbname,user_name(@schem),@tablename,user_name(@grantor),
            user_name(@grantee),
            if @deleteauth = 'Y' or @deleteauth = 'G' then 'DELETE' else 'null' endif,
            if @deleteauth = 'G' then 'YES' else 'NO' endif
        insert into dbo.jdbc_tableprivileges
          select @dbname,user_name(@schem),@tablename,user_name(@grantor),
            user_name(@grantee),
            if @updateauth = 'Y' or @updateauth = 'G' then 'UPDATE' else 'null' endif,
            if @updateauth = 'G' then 'YES' else 'NO' endif
        insert into dbo.jdbc_tableprivileges
          select @dbname,user_name(@schem),@tablename,user_name(@grantor),
            user_name(@grantee),
            if @alterauth = 'Y' or @alterauth = 'G' then 'ALTER' else 'null' endif,
            if @alterauth = 'G' then 'YES' else 'NO' endif
        insert into dbo.jdbc_tableprivileges
          select @dbname,user_name(@schem),@tablename,user_name(@grantor),
            user_name(@grantee),
            if @referenceauth = 'Y' or @referenceauth = 'G' then 'REFERENCE'
            else 'null'
            endif,if @referenceauth = 'G' then 'YES' else 'NO' endif
        fetch next getid2 into @tableid,@schem,@grantor,@grantee,@tablename,@selectauth,
          @insertauth,@deleteauth,@updateauth,@alterauth,
          @referenceauth
      end
    close getid2
  end
select distinct * from dbo.jdbc_tableprivileges where PRIVILEGE <> 'null'
  and TABLE_SCHEM like @table_owner escape '\\'
  order by TABLE_SCHEM asc,TABLE_NAME asc,PRIVILEGE asc
commit transaction
delete from dbo.jdbc_tableprivileges
