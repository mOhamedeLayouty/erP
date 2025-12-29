-- PF: UNKNOWN_SCHEMA.sp_jdbc_getschemas
-- proc_id: 337
-- generated_at: 2025-12-29T13:53:28.790Z

create procedure dbo.sp_jdbc_getschemas( 
  @sp_qualifier varchar(128)= null,
  @sp_owner varchar(128)= null ) 
as
if @sp_owner is null
  select @sp_owner = '%'
if @sp_qualifier is null
  select @sp_qualifier = db_name()
execute('select TABLE_SCHEM=name, TABLE_CATALOG='''+@sp_qualifier+''' from '
  +@sp_qualifier+'..sysusers where '
  +' name like '''+@sp_owner
  +''' order by name')
