-- PF: UNKNOWN_SCHEMA.xp_stopmail
-- proc_id: 42
-- generated_at: 2025-12-29T13:53:28.703Z

create function dbo.xp_stopmail()
returns integer
begin
  return(dbo.xp_real_stopmail(connection_property('Number')))
end
