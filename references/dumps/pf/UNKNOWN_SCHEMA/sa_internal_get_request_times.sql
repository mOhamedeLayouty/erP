-- PF: UNKNOWN_SCHEMA.sa_internal_get_request_times
-- proc_id: 189
-- generated_at: 2025-12-29T13:53:28.746Z

create procedure dbo.sa_internal_get_request_times( 
  in filename long varchar,
  in conn_id unsigned integer,
  in first_file integer,
  in num_files integer ) 
internal name 'sa_get_request_times'
