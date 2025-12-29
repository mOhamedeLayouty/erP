-- PF: UNKNOWN_SCHEMA.hour
-- proc_id: 364
-- generated_at: 2025-12-29T13:53:28.797Z

create function DBA.hour( in dt DATETIME ) 
returns integer
begin
  return(datepart(hh,dt))
end
