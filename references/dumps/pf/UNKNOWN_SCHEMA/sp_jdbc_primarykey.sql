-- PF: UNKNOWN_SCHEMA.sp_jdbc_primarykey
-- proc_id: 341
-- generated_at: 2025-12-29T13:53:28.791Z

create procedure dbo.sp_jdbc_primarykey( 
  @table_qualifier varchar(128),
  @table_owner varchar(128),
  @table_name varchar(128) ) as
declare @id integer
declare @tableowner varchar(128)
if(@table_owner is null) select @table_owner = '%'
if(@table_name is null)
  begin
    raiserror 17208 'Null is not allowed for parameter TABLE NAME '
    return(1)
  end
if(select count() from dbo.sysobjects
    where user_name(uid) like @table_owner escape '\\'
    and('"'+name+'"' = @table_name or name = @table_name)) = 0
  begin
    raiserror 17208
      'There is no object with the specified owner/name combination'
    return(1)
  end
select TABLE_CAT=dbo.sp_jconnect_trimit(db_name()),
  TABLE_SCHEM=dbo.sp_jconnect_trimit(user_name(t.creator)),
  TABLE_NAME=dbo.sp_jconnect_trimit(@table_name),
  COLUMN_NAME=dbo.sp_jconnect_trimit(column_name),
  KEY_SEQ=i.sequence+1,
  PK_NAME=dbo.sp_jconnect_trimit(column_name)
  from SYS.SYSIDXCOL as i join SYS.SYSCOLUMN as c,SYS.SYSTABLE as t,SYS.SYSIDX as ix
  where c.pkey = 'Y'
  and c.table_id = t.table_id
  and ix.table_id = t.table_id
  and i.table_id = ix.table_id
  and i.index_id = ix.index_id
  and ix.index_category = 1
  and t.table_name = @table_name
  and user_name(t.creator) like @table_owner escape '\\'
  order by COLUMN_NAME asc
