-- PF: UNKNOWN_SCHEMA.sa_oledb_column_privileges
-- proc_id: 289
-- generated_at: 2025-12-29T13:53:28.776Z

create procedure dbo.sa_oledb_column_privileges( 
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inTableName char(128) default '',
  in inColumnName char(128) default '',
  in inGrantor char(128) default '',
  in inGrantee char(128) default '' ) 
result( 
  GRANTOR char(128),
  GRANTEE char(128),
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  COLUMN_NAME char(128),
  COLUMN_GUID uniqueidentifier,
  COLUMN_PROPID unsigned integer,
  PRIVILEGE_TYPE char(20),
  IS_GRANTABLE bit ) dynamic result sets 1
on exception resume
begin
  if inTableCatalog = db_name() or inTableCatalog = '' then
    select distinct
      (select user_name from SYS.SYSUSERPERMS where user_id = grantor) as GRANTOR,
      (select user_name from SYS.SYSUSERPERMS where user_id = member.user_id) as GRANTEE,
      db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      COLUMN_NAME,
      cast(null as uniqueidentifier) as COLUMN_GUID,
      cast(null as unsigned integer) as COLUMN_PROPID,
      priv_type as PRIVILEGE_TYPE,
      cast(if(case priv_type
      when 'select' then selectauth
      when 'delete' then deleteauth
      when 'update' then updateauth
      when 'insert' then insertauth
      when 'references' then referenceauth end)
       = 'G' then 1 else 0 endif as bit) as IS_GRANTABLE
      from SYS.SYSUSERPERMS as member
        ,SYS.SYSCOLUMN key join SYS.SYSTABLE
        join SYS.SYSTABLEPERM
        on(SYSTABLEPERM.stable_id = SYSTABLE.table_id)
        join SYS.SYSUSERPERMS
        on(SYSUSERPERMS.user_id = SYSTABLE.creator)
        ,(select case row_num
          when 1 then 'select'
          when 2 then 'delete'
          when 3 then 'update'
          when 4 then 'insert'
          when 5 then 'references' end
          from dbo.RowGenerator
          where row_num <= 4) as Privs( priv_type ) 
      where member.user_id <> SYSTABLE.creator
      and((selectauth <> 'N' and priv_type = 'select')
      or(deleteauth <> 'N' and priv_type = 'delete')
      or(updateauth <> 'N' and priv_type = 'update')
      or(insertauth <> 'N' and priv_type = 'insert')
      or(referenceauth <> 'N' and priv_type = 'references'))
      and SYSUSERPERMS.user_name
       = if inTableSchema = '' then
        SYSUSERPERMS.user_name
      else inTableSchema
      endif
      and table_name
       = if inTableName = '' then table_name
      else inTableName
      endif and column_name
       = if inColumnName = '' then
        column_name
      else inColumnName
      endif
      and(member.user_id = SYSTABLEPERM.grantee
      or member.user_id
       = any(select group_member from SYS.SYSGROUP
        where group_id = SYSTABLEPERM.grantee)
      or member.user_id
       = any(select group_member from SYS.SYSGROUP
        where group_id
         = any(select group_member from SYS.SYSGROUP
          where group_id = SYSTABLEPERM.grantee))
      or member.user_id
       = any(select group_member from SYS.SYSGROUP
        where group_id
         = any(select group_member from SYS.SYSGROUP
          where group_id
           = any(select group_member from SYS.SYSGROUP
            where group_id = SYSTABLEPERM.grantee))))
      and GRANTOR
       = if inGrantor = '' then GRANTOR
      else inGrantor
      endif and GRANTEE
       = if inGrantee = '' then GRANTEE
      else inGrantee
      endif union all
    select u.user_name as GRANTOR,
      u.user_name as GRANTEE,
      db_name() as TABLE_CATALOG,
      u.user_name as TABLE_SCHEMA,
      t.table_name as TABLE_NAME,
      COLUMN_NAME,
      cast(null as uniqueidentifier) as COLUMN_GUID,
      cast(null as unsigned integer) as COLUMN_PROPID,
      Privs.priv_type as PRIVILEGE_TYPE,
      cast(1 as bit)
      from SYS.SYSUSERPERMS as u join SYS.SYSTABLE as t join SYS.SYSCOLUMN as c
        ,(select case row_num
          when 1 then 'select'
          when 2 then 'delete'
          when 3 then 'update'
          when 4 then 'insert'
          when 5 then 'references' end
          from dbo.RowGenerator
          where row_num <= 5) as Privs( priv_type ) 
      where u.user_name
       = if inTableSchema = '' then
        u.user_name
      else inTableSchema
      endif
      and table_name
       = if inTableName = '' then
        table_name
      else inTableName
      endif
      and column_name
       = if inColumnName = '' then
        column_name
      else inColumnName
      endif
      and GRANTOR
       = if inGrantor = '' then GRANTOR
      else inGrantor
      endif and GRANTEE
       = if inGrantee = '' then GRANTEE
      else inGrantee
      endif union all
    select(select user_name from SYS.SYSUSERPERMS where user_id = SYSCOLPERM.grantor) as GRANTOR,
      (select user_name from SYS.SYSUSERPERMS where user_id = SYSCOLPERM.grantee) as GRANTEE,
      db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      COLUMN_NAME,
      cast(null as uniqueidentifier) as COLUMN_GUID,
      cast(null as unsigned integer) as COLUMN_PROPID,
      'UPDATE' as PRIVILEGE_TYPE,
      cast(if UPDATECOLS = 'G' then 1 else 0 endif as bit) as IS_GRANTABLE
      from SYS.SYSTABLEPERM,SYS.SYSCOLPERM
        join SYS.SYSCOLUMN
        join SYS.SYSTABLE
        join SYS.SYSUSERPERMS
      where SYSTABLEPERM.stable_id = SYSTABLE.table_id
      and updateauth = 'N' and updatecols <> 'N'
      and SYSUSERPERMS.user_name
       = if inTableSchema = '' then
        if inTableName = '' then SYSUSERPERMS.user_name
        else dbo.sa_oledb_getowner('table',inTableName)
        endif
      else inTableSchema
      endif
      and table_name
       = if inTableName = '' then table_name
      else inTableName
      endif
      and column_name
       = if inColumnName = '' then column_name
      else inColumnName
      endif
      and GRANTOR
       = if inGrantor = '' then GRANTOR
      else inGrantor
      endif and GRANTEE
       = if inGrantee = '' then GRANTEE
      else inGrantee
      endif order by 3 asc,4 asc,5 asc,6 asc,9 asc
  else
    select null as GRANTOR,
      null as GRANTEE,
      null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as COLUMN_NAME,
      null as COLUMN_GUID,
      null as COLUMN_PROPID,
      null as PRIVILEGE_TYPE,
      null as IS_GRANTABLE
  end if
end
