-- PF: UNKNOWN_SCHEMA.sp_tsql_feature_not_supported
-- proc_id: 2
-- generated_at: 2025-12-29T13:53:28.690Z

create procedure dbo.sp_tsql_feature_not_supported()
begin
  declare feature_not_supported exception for sqlstate value '0AW02';
  signal feature_not_supported
end
