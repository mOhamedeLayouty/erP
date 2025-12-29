-- PF: UNKNOWN_SCHEMA.sa_oledb_table_privileges
-- proc_id: 300
-- generated_at: 2025-12-29T13:53:28.780Z

create procedure dbo.sa_oledb_table_privileges( 
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inTableName char(128) default '',
  in inGrantor char(128) default '',
  in inGrantee char(128) default '' ) 
result( 
  GRANTOR char(128),
  GRANTEE char(128),
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  PRIVILEGE_TYPE char(20),
  IS_GRANTABLE bit ) dynamic result sets 1
on exception resume
begin
  if inTableCatalog = db_name() or inTableCatalog = '' then
    select(select user_name from SYS.SYSUSERPERMS where user_id = grantor) as GRANTOR,
      (select user_name from SYS.SYSUSERPERMS where user_id = member.user_id) as GRANTEE,
      db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      priv_type as PRIVILEGE_TYPE,
      cast(if(case priv_type
      when 'select' then selectauth
      when 'delete' then deleteauth
      when 'update' then updateauth
      when 'insert' then insertauth
      when 'references' then referenceauth end)
       = 'G' then 1 else 0 endif as bit) as IS_GRANTABLE
      from SYS.SYSTABLEPERM,SYS.SYSUSERPERMS as member,SYS.SYSTABLE
        join SYS.SYSUSERPERMS
        ,(select case row_num
          when 1 then 'select'
          when 2 then 'delete'
          when 3 then 'update'
          when 4 then 'insert'
          when 5 then 'references' end
          from dbo.RowGenerator
          where row_num <= 4) as Privs( priv_type ) 
      where SYSTABLEPERM.stable_id = SYSTABLE.table_id
      and member.user_id <> SYSTABLE.creator
      and((selectauth <> 'N' and priv_type = 'select')
      or(deleteauth <> 'N' and priv_type = 'delete')
      or(updateauth <> 'N' and priv_type = 'update')
      or(insertauth <> 'N' and priv_type = 'insert')
      or(referenceauth <> 'N' and priv_type = 'references'))
      and SYSUSERPERMS.user_name
       = if inTableSchema = '' then SYSUSERPERMS.user_name
      else inTableSchema
      endif and table_name
       = if inTableName = '' then table_name
      else inTableName
      endif and(member.user_id = SYSTABLEPERM.grantee
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
    select SYSUSERPERMS.user_name as GRANTOR,
      SYSUSERPERMS.user_name as GRANTEE,
      db_name() as TABLE_CATALOG,
      SYSUSERPERMS.user_name as TABLE_SCHEMA,
      SYSTABLE.table_name as TABLE_NAME,
      Privs.priv_type as PRIVILEGE_TYPE,
      cast(1 as bit)
      from SYS.SYSUSERPERMS join SYS.SYSTABLE
        ,(select case row_num
          when 1 then 'select'
          when 2 then 'delete'
          when 3 then 'update'
          when 4 then 'insert'
          when 5 then 'references' end
          from dbo.RowGenerator
          where row_num <= 4) as Privs( priv_type ) 
      where SYSUSERPERMS.user_name
       = if inTableSchema = '' then
        if inTableName = '' then SYSUSERPERMS.user_name
        else dbo.sa_oledb_getowner('table',inTableName)
        endif
      else inTableSchema
      endif and table_name
       = if inTableName = '' then table_name
      else inTableName
      endif and GRANTOR
       = if inGrantor = '' then GRANTOR
      else inGrantor
      endif and GRANTEE
       = if inGrantee = '' then GRANTEE
      else inGrantee
      endif order by 3 asc,4 asc,5 asc,6 asc
  else
    select null as GRANTOR,
      null as GRANTEE,
      null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as PRIVILEGE_TYPE,
      null as IS_GRANTABLE
  end if
end
