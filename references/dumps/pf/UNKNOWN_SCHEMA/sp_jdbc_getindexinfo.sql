-- PF: UNKNOWN_SCHEMA.sp_jdbc_getindexinfo
-- proc_id: 347
-- generated_at: 2025-12-29T13:53:28.793Z

create procedure dbo.sp_jdbc_getindexinfo( 
  @table_qualifier varchar(128)= null,
  @table_owner varchar(128)= null,
  @table_name varchar(128),
  @unique varchar(5),
  @approximate varchar(5) ) 
as
declare @is_unique char(5)
declare @owner varchar(128)
declare @table_id integer
declare @colID integer
declare @indexID integer
declare @sequence integer
declare @asc_or_desc char(5)
if(@unique = '1' or @unique = 'true')
  select @is_unique = 1
else
  select @is_unique = 'false'
if(@table_owner is null)
  begin
    select @table_owner = '%'
  end
if(@table_name is null)
  begin
    raiserror 17208 'Null is not allowed for parameter TABLE NAME '
    return(1)
  end
if(select count() from dbo.sysobjects
    where user_name(uid) like @table_owner escape '\\'
    and name = @table_name) = 0
  begin
    raiserror 17208
      'There is no object with the specified owner/name combination'
    return(1)
  end
if(@approximate = 'false' or @approximate = '0')
  begin
    checkpoint
  end
begin transaction
delete from dbo.jdbc_indexhelp
delete from dbo.jdbc_indexhelp2
insert into dbo.jdbc_indexhelp
  select icreator,iname,
    if("left"(trim(indextype),1) = 'N') then 1 else 0 endif,
    null
    from SYS.SYSINDEXES
    where tname = @table_name
    and creator like @table_owner escape '\\'
declare owner_cur dynamic scroll cursor for select @table_owner=user_name(uid) from sysobjects
    where name like @table_name escape '\\'
    and user_name(uid) like @table_owner escape '\\'
open owner_cur
fetch next owner_cur
  into @owner
while(@@sqlstatus = 0)
  begin
    select @table_id = table_id from SYS.SYSTABLE
      where table_name = @table_name and creator = user_id(@owner)
    declare colIDCursor dynamic scroll cursor for select SYS.SYSIXCOL.column_id,
        SYS.SYSIXCOL.index_id,
        SYS.SYSIXCOL.sequence,
        SYS.SYSIXCOL."order"
        from SYS.SYSIXCOL join SYS.SYSCOLUMN
        where SYS.SYSIXCOL.table_id = @table_id
    open colIDCursor
    fetch next colIDCursor into @colID,@indexID,@sequence,@asc_or_desc
    while(@@sqlstatus = 0)
      begin
        insert into dbo.jdbc_indexhelp2
          select db_name(),user_name(idx.creator),table_name,
            (select non_unique from dbo.jdbc_indexhelp
              where iname = index_name and icreator = @owner),
            db_name(),index_name,
            3,
            @sequence+1,
            (select column_name from SYS.SYSCOLUMN join SYS.SYSTABLE
              where SYS.SYSTABLE.table_id = @table_id and column_id = @colID),
            @asc_or_desc,
            count,
            0,
            null
            from SYS.SYSTABLE as tab join SYS.SYSINDEX as idx on(idx.table_id = tab.table_id)
            where tab.table_id = @table_id and idx.index_id = @indexID
        fetch next colIDCursor into @colID,@indexID,@sequence,@asc_or_desc
      end
    close colIDCursor
    fetch next owner_cur
      into @owner
  end
close owner_cur
select distinct * from dbo.jdbc_indexhelp2
  where NON_UNIQUE <> @is_unique and NON_UNIQUE is not null
  order by NON_UNIQUE asc,TYPE asc,INDEX_NAME asc,ORDINAL_POSITION asc
commit transaction
delete from dbo.jdbc_indexhelp
delete from dbo.jdbc_indexhelp2
