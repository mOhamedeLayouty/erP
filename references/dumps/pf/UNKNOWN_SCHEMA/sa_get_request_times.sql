-- PF: UNKNOWN_SCHEMA.sa_get_request_times
-- proc_id: 190
-- generated_at: 2025-12-29T13:53:28.747Z

create procedure dbo.sa_get_request_times( 
  in filename long varchar default null,
  in conn_id unsigned integer default 0,
  in first_file integer default-1,
  in num_files integer default 1 ) 
begin
  if(filename is null) then
    set filename = property('RequestLogFile')
  end if;
  if(filename <> '') then
    truncate table dbo.satmp_request_time;
    truncate table dbo.satmp_request_hostvar;
    truncate table dbo.satmp_request_block;
    call dbo.sa_internal_get_request_times(filename,conn_id,first_file,num_files);
    commit work
  end if
end
