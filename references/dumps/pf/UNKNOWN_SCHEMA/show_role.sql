-- PF: UNKNOWN_SCHEMA.show_role
-- proc_id: 38
-- generated_at: 2025-12-29T13:53:28.702Z

create function dbo.show_role()
returns char(128)
on exception resume
begin
  return(null)
end
