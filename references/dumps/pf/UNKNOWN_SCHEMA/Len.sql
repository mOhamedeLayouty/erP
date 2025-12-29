-- PF: UNKNOWN_SCHEMA.Len
-- proc_id: 365
-- generated_at: 2025-12-29T13:53:28.798Z

create function DBA.Len( in str varchar(1000) ) 
returns integer
begin
  return(length(str))
end
