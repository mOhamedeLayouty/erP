-- PF: UNKNOWN_SCHEMA.sa_internal_system_task
-- proc_id: 138
-- generated_at: 2025-12-29T13:53:28.733Z

create function dbo.sa_internal_system_task( 
  in command long varchar ) 
returns integer
internal name 'sa_systemtask'
