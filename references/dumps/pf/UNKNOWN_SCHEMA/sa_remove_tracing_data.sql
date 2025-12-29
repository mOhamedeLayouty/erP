-- PF: UNKNOWN_SCHEMA.sa_remove_tracing_data
-- proc_id: 207
-- generated_at: 2025-12-29T13:53:28.753Z

create procedure dbo.sa_remove_tracing_data( in log_session_id unsigned integer ) 
begin
  call dbo.sp_checkperms('PROFILE');
  if log_session_id < 1 then
    return
  end if;
  delete from sa_diagnostic_optrewrite where logging_session_id = log_session_id;
  delete from sa_diagnostic_optorder where logging_session_id = log_session_id;
  delete from sa_diagnostic_optquantifier where logging_session_id = log_session_id;
  delete from sa_diagnostic_optjoinstrategy where logging_session_id = log_session_id;
  delete from sa_diagnostic_optblock where logging_session_id = log_session_id;
  delete from sa_diagnostic_statistics where logging_session_id = log_session_id;
  delete from sa_diagnostic_cachecontents where logging_session_id = log_session_id;
  delete from sa_diagnostic_internalvariable where logging_session_id = log_session_id;
  delete from sa_diagnostic_hostvariable where logging_session_id = log_session_id;
  delete from sa_diagnostic_deadlock where logging_session_id = log_session_id;
  delete from sa_diagnostic_blocking where logging_session_id = log_session_id;
  delete from sa_diagnostic_request where logging_session_id = log_session_id;
  delete from sa_diagnostic_cursor where logging_session_id = log_session_id;
  delete from sa_diagnostic_query where logging_session_id = log_session_id;
  delete from sa_diagnostic_statement where logging_session_id = log_session_id;
  delete from sa_diagnostic_connection where logging_session_id = log_session_id;
  commit work
end
