-- PF: UNKNOWN_SCHEMA.sa_oledb_indexes
-- proc_id: 292
-- generated_at: 2025-12-29T13:53:28.777Z

create procedure dbo.sa_oledb_indexes( 
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inIndexName char(128) default '',
  in inType unsigned smallint default 1,
  in inTableName char(128) default '' ) 
result( 
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  INDEX_CATALOG char(128),
  INDEX_SCHEMA char(128),
  INDEX_NAME char(128),
  PRIMARY_KEY bit,
  "UNIQUE" bit,
  CLUSTERED bit,
  TYPE unsigned smallint,
  FILL_FACTOR integer,
  INITIAL_SIZE integer,
  NULLS integer,
  SORT_BOOKMARKS bit,
  AUTO_UPDATE bit,
  NULL_COLLATION integer,
  ORDINAL_POSITION smallint,
  COLUMN_NAME char(128),
  COLUMN_GUID uniqueidentifier,
  COLUMN_PROPID unsigned integer,
  COLLATION smallint,
  CARDINALITY unsigned bigint,
  PAGES integer,
  FILTER_CONDITION char(128),
  "INTEGRATED" bit ) dynamic result sets 1
on exception resume
begin
  if inTableCatalog = db_name() or inTableCatalog = '' then
    select db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      db_name() as INDEX_CATALOG,
      SYSUSERPERMS.user_name as INDEX_SCHEMA,
      table_name as INDEX_NAME,
      cast(1 as bit) as PRIMARY_KEY,
      cast(1 as bit) as "UNIQUE",
      cast(0 as bit) as CLUSTERED,
      cast(1 as unsigned smallint) as TYPE,
      cast(null as integer) as FILL_FACTOR,
      cast(null as integer) as INITIAL_SIZE,
      cast(null as integer) as NULLS,
      cast(0 as bit) as SORT_BOOKMARKS,
      cast(1 as bit) as AUTO_UPDATE,
      cast(8 as integer) as NULL_COLLATION,
      cast((select count() from SYS.SYSCOLUMN
        where table_id = SYSTABLE.table_id
        and column_id <= SYSCOLUMN.column_id
        and pkey = 'Y') as smallint) as ORDINAL_POSITION,
      column_name as COLUMN_NAME,
      cast(null as uniqueidentifier) as COLUMN_GUID,
      cast(null as unsigned integer) as COLUMN_PROPID,
      cast(1 as smallint) as COLLATION,
      cast(count as unsigned bigint) as CARDINALITY,
      cast(null as integer) as PAGES,
      cast(null as char(128)) as FILTER_CONDITION,
      cast(0 as bit) as "INTEGRATED"
      from SYS.SYSCOLUMN
        join SYS.SYSTABLE
        join SYS.SYSUSERPERMS
      where user_name
       = if inTableSchema = '' then
        user_name
      else inTableSchema
      endif
      and TABLE_NAME
       = if inTableName = '' then
        TABLE_NAME
      else inTableName
      endif
      and INDEX_NAME
       = if inIndexName = '' then
        INDEX_NAME
      else inIndexName
      endif
      and pkey = 'Y' union all
    select db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      db_name() as INDEX_CATALOG,
      SYSUSERPERMS.user_name as INDEX_SCHEMA,
      index_name as INDEX_NAME,
      cast(0 as bit) as PRIMARY_KEY,
      cast(if "unique" = 'Y' or "unique" = 'U' then 1 else 0 endif as bit) as "UNIQUE",
      cast(if ISNULL((select st.clustered_index_id
        from SYS.SYSTAB as st
        where st.table_id = SYSTABLE.table_id),-1)
       = SYSIXCOL.index_id then 1 else 0 endif as bit) as CLUSTERED,
      cast(1 as unsigned smallint) as TYPE,
      cast(null as integer) as FILL_FACTOR,
      cast(null as integer) as INITIAL_SIZE,
      cast(null as integer) as NULLS,
      cast(0 as bit) as SORT_BOOKMARKS,
      cast(1 as bit) as AUTO_UPDATE,
      cast(8 as integer) as NULL_COLLATION,
      cast(sequence+1 as smallint) as ORDINAL_POSITION,
      column_name as COLUMN_NAME,
      cast(null as uniqueidentifier) as COLUMN_GUID,
      cast(null as unsigned integer) as COLUMN_PROPID,
      cast(if "order" = 'A' then 1 else 2 endif as smallint) as COLLATION,
      cast(count as unsigned bigint) as CARDINALITY,
      cast(null as integer) as PAGES,
      cast(null as char(128)) as FILTER_CONDITION,
      cast(0 as bit) as "INTEGRATED"
      from SYS.SYSCOLUMN
        join SYS.SYSIXCOL
        join SYS.SYSINDEX
        join SYS.SYSTABLE
        join SYS.SYSUSERPERMS
      where user_name
       = if inTableSchema = '' then
        if inTableName = '' then user_name
        else dbo.sa_oledb_getowner('table',inTableName)
        endif
      else inTableSchema
      endif
      and TABLE_NAME
       = if inTableName = '' then TABLE_NAME
      else inTableName
      endif
      and INDEX_NAME
       = if inIndexName = '' then INDEX_NAME
      else inIndexName
      endif
      order by 8 asc,10 asc,4 asc,5 asc,6 asc,17 asc
  else
    select null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as INDEX_CATALOG,
      null as INDEX_SCHEMA,
      null as INDEX_NAME,
      null as PRIMARY_KEY,
      null as "UNIQUE",
      null as CLUSTERED,
      null as TYPE,
      null as FILL_FACTOR,
      null as INITIAL_SIZE,
      null as NULLS,
      null as SORT_BOOKMARKS,
      null as AUTO_UPDATE,
      null as NULL_COLLATION,
      null as ORDINAL_POSITION,
      null as COLUMN_NAME,
      null as COLUMN_GUID,
      null as COLUMN_PROPID,
      null as COLLATION,
      null as CARDINALITY,
      null as PAGES,
      null as FILTER_CONDITION,
      null as "INTEGRATED"
  end if
end
