-- PF: UNKNOWN_SCHEMA.xp_stopsmtp
-- proc_id: 46
-- generated_at: 2025-12-29T13:53:28.704Z

create function dbo.xp_stopsmtp()
returns integer
begin
  return(dbo.xp_real_stopsmtp(connection_property('Number')))
end
