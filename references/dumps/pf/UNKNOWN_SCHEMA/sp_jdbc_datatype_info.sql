-- PF: UNKNOWN_SCHEMA.sp_jdbc_datatype_info
-- proc_id: 327
-- generated_at: 2025-12-29T13:53:28.787Z

create procedure dbo.sp_jdbc_datatype_info
as
select TYPE_NAME,
  DATA_TYPE,
  'PRECISION'=typelength,
  LITERAL_PREFIX,
  LITERAL_SUFFIX,
  CREATE_PARAMS,
  NULLABLE,
  CASE_SENSITIVE,
  SEARCHABLE,
  UNSIGNED_ATTRIBUTE,
  FIXED_PREC_SCALE,
  AUTO_INCREMENT,
  LOCAL_TYPE_NAME,
  MINIMUM_SCALE,
  MAXIMUM_SCALE,
  SQL_DATA_TYPE,
  SQL_DATETIME_SUB,
  NUM_PREC_RADIX
  -- INTERVAL_PRECISION
  from dbo.spt_jdatatype_info
  order by DATA_TYPE asc,TYPE_NAME asc
return(0)
