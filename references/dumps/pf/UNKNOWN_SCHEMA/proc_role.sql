-- PF: UNKNOWN_SCHEMA.proc_role
-- proc_id: 37
-- generated_at: 2025-12-29T13:53:28.702Z

create function dbo.proc_role( 
  in @role_type char(10) ) 
returns integer
on exception resume
begin
  return(0)
end
