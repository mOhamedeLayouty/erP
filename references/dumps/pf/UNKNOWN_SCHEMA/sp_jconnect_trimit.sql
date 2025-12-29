-- PF: UNKNOWN_SCHEMA.sp_jconnect_trimit
-- proc_id: 326
-- generated_at: 2025-12-29T13:53:28.787Z

create function dbo.sp_jconnect_trimit( in @iString varchar(255) ) 
returns varchar(255)
begin
  return(trim(@iString))
end
