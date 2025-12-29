-- PF: UNKNOWN_SCHEMA.sp_jdbc_getversioncolumns
-- proc_id: 346
-- generated_at: 2025-12-29T13:53:28.793Z

create procedure dbo.sp_jdbc_getversioncolumns( 
  @table_qualifier varchar(128)= null,
  @table_owner varchar(128)= null,
  @table_name varchar(128) ) 
as
declare @id integer
if(@table_owner is null) select @table_owner = '%'
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
    return(1)
  end
begin transaction
delete from dbo.jdbc_versions
declare curs2 dynamic scroll cursor for select table_name from SYS.SYSTABLE
    where table_name like @table_name escape '\\'
    and user_name(creator) like @table_owner escape '\\'
open curs2
fetch next curs2
  into @table_name
while(@@sqlstatus = 0)
  begin
    insert into dbo.jdbc_versions
      select 0,
        dbo.sp_jconnect_trimit(cname),
        (select DATA_TYPE from dbo.spt_jdatatype_info
          where TYPE_NAME = (select if coltype = 'integer' then
              'int' else coltype endif)),
        dbo.sp_jconnect_trimit(coltype),
        length,
        length,
        syslength,
        1
        from SYS.SYSCOLUMNS
        where default_value = 'autoincrement'
        and tname like @table_name escape '\\'
    fetch next curs2
      into @table_name
  end
close curs2
select * from dbo.jdbc_versions
commit transaction
