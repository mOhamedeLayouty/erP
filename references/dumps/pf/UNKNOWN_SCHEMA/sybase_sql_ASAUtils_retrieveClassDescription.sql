-- PF: UNKNOWN_SCHEMA.sybase_sql_ASAUtils_retrieveClassDescription
-- proc_id: 97
-- generated_at: 2025-12-29T13:53:28.720Z

create function dbo.sybase_sql_ASAUtils_retrieveClassDescription( in p long varchar ) 
returns long varchar
external name 'sybase.sql.ASAUtils.retrieveClassDescription (Ljava/lang/String;)Ljava/lang/String;' language java
