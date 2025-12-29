-- PF: UNKNOWN_SCHEMA.GetDate
-- proc_id: 361
-- generated_at: 2025-12-29T13:53:28.797Z

create function DBA.GetDate() /* parameters,... */
returns date
begin
  return(today())
end
