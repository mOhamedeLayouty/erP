-- PF: UNKNOWN_SCHEMA.sp_jdbc_getudts
-- proc_id: 350
-- generated_at: 2025-12-29T13:53:28.794Z

create procedure dbo.sp_jdbc_getudts( 
  @table_qualifier varchar(128)= null,
  @table_owner varchar(128)= null,
  @type_name_pattern varchar(128),
  @types varchar(128) ) 
as
declare @empty_string varchar(1)
declare @empty_int integer
select @empty_string = ''
select @empty_int = 0
select TYPE_CAT=@empty_string,
  TYPE_SCHEM=@empty_string,
  TYPE_NAME=@empty_string,
  CLASS_NAME=@empty_string,
  DATA_TYPE=@empty_int,
  REMARKS=@empty_string
  where 1 = 2
