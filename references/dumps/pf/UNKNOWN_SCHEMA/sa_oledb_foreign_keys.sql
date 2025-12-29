-- PF: UNKNOWN_SCHEMA.sa_oledb_foreign_keys
-- proc_id: 291
-- generated_at: 2025-12-29T13:53:28.777Z

create procedure dbo.sa_oledb_foreign_keys( 
  in inPKTableCatalog char(128) default '',
  in inPKTableSchema char(128) default '',
  in inPKTableName char(128) default '',
  in inFKTableCatalog char(128) default '',
  in inFKTableSchema char(128) default '',
  in inFKTableName char(128) default '' ) 
result( 
  PK_TABLE_CATALOG char(128),
  PK_TABLE_SCHEMA char(128),
  PK_TABLE_NAME char(128),
  PK_COLUMN_NAME char(128),
  PK_COLUMN_GUID uniqueidentifier,
  PK_COLUMN_PROPID unsigned integer,
  FK_TABLE_CATALOG char(128),
  FK_TABLE_SCHEMA char(128),
  FK_TABLE_NAME char(128),
  FK_COLUMN_NAME char(128),
  FK_COLUMN_GUID uniqueidentifier,
  FK_COLUMN_PROPID unsigned integer,
  ORDINAL unsigned integer,
  UPDATE_RULE char(20),
  DELETE_RULE char(20),
  PK_NAME char(128),
  FK_NAME char(128),
  DEFERRABILITY smallint ) dynamic result sets 1
on exception resume
begin
  if(inPKTableCatalog = db_name() or inPKTableCatalog = '')
    and(inFKTableCatalog = db_name() or inFKTableCatalog = '') then
    select db_name() as PK_TABLE_CATALOG,
      PKUser.user_name as PK_TABLE_SCHEMA,
      PKTable.table_name as PK_TABLE_NAME,
      PKColumn.column_name as PK_COLUMN_NAME,
      cast(null as uniqueidentifier) as PK_COLUMN_GUID,
      cast(null as unsigned integer) as PK_COLUMN_PROPID,
      db_name() as FK_TABLE_CATALOG,
      FKUser.user_name as FK_TABLE_SCHEMA,
      FKTable.table_name as FK_TABLE_NAME,
      FKColumn.column_name as FK_COLUMN_NAME,
      cast(null as uniqueidentifier) as FK_COLUMN_GUID,
      cast(null as unsigned integer) as FK_COLUMN_PROPID,
      cast((select count() from SYS.SYSFKCOL as other
        where foreign_table_id = SYSFOREIGNKEY.foreign_table_id
        and foreign_key_id = SYSFOREIGNKEY.foreign_key_id
        and primary_column_id <= SYSFKCOL.primary_column_id) as unsigned integer) as ORDINAL,
      cast(isnull(
      (select if referential_action = 'C' then 0
        else if referential_action = 'N' then 2
          else 3
          endif
        endif from SYS.SYSTRIGGER
        where table_id = SYSFOREIGNKEY.primary_table_id
        and foreign_table_id = SYSFOREIGNKEY.foreign_table_id
        and foreign_key_id = SYSFOREIGNKEY.foreign_key_id and event = 'C'),
      1) as smallint) as UPDATE_RULE,
      cast(isnull(
      (select if referential_action = 'C' then 0
        else if referential_action = 'N' then 2
          else 3
          endif
        endif from SYS.SYSTRIGGER
        where table_id = SYSFOREIGNKEY.primary_table_id
        and foreign_table_id = SYSFOREIGNKEY.foreign_table_id
        and foreign_key_id = SYSFOREIGNKEY.foreign_key_id
        and event = 'D'),
      1) as smallint) as DELETE_RULE,
      PKConst.constraint_name as PK_NAME,
      role as FK_NAME,
      cast(if SYSFOREIGNKEY.check_on_commit = 'Y' then 1
      else 2
      endif as smallint) as DEFERRABILITY
      from SYS.SYSUSERPERMS as PKUser
        join SYS.SYSTABLE as PKTable
        join SYS.SYSCONSTRAINT as PKConst on(PKTABLE.object_id = PKConst.table_object_id)
        join SYS.SYSCOLUMN as PKColumn,SYS.SYSUSERPERMS as FKUser
        join SYS.SYSTABLE as FKTable
        join SYS.SYSCOLUMN as FKColumn,SYS.SYSFOREIGNKEY
        join SYS.SYSFKCOL
      where PKTable.table_id = SYSFOREIGNKEY.primary_table_id
      and PKColumn.column_id = SYSFKCOL.primary_column_id
      and FKTable.table_id = SYSFOREIGNKEY.foreign_table_id
      and FKColumn.column_id = SYSFKCOL.foreign_column_id
      and PKUser.user_name
       = if inPKTableSchema = '' then
        if inPKTableName = '' then PKUser.user_name
        else dbo.sa_oledb_getowner('table',inPKTableName)
        endif
      else inPKTableSchema
      endif
      and PKTable.table_name
       = if inPKTableName = '' then PKTable.table_name
      else inPKTableName
      endif
      and FKUser.user_name
       = if inFKTableSchema = '' then FKUser.user_name
      else inFKTableSchema
      endif
      and FKTable.table_name
       = if inFKTableName = '' then FKTable.table_name
      else inFKTableName
      endif
      and PKConst.constraint_type = 'P'
      order by 5 asc,6 asc,7 asc,1 asc,2 asc,3 asc,9 asc
  else
    select null as PK_TABLE_CATALOG,
      null as PK_TABLE_SCHEMA,
      null as PK_TABLE_NAME,
      null as PK_COLUMN_NAME,
      null as PK_COLUMN_GUID,
      null as PK_COLUMN_PROPID,
      null as FK_TABLE_CATALOG,
      null as FK_TABLE_SCHEMA,
      null as FK_TABLE_NAME,
      null as FK_COLUMN_NAME,
      null as FK_COLUMN_GUID,
      null as FK_COLUMN_PROPID,
      null as ORDINAL,
      null as UPDATE_RULE,
      null as DELETE_RULE,
      null as PK_NAME,
      null as FK_NAME,
      null as DEFERRABILITY
  end if
end
