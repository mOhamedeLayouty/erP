-- PF: UNKNOWN_SCHEMA.sa_truncate_trace_data
-- proc_id: 324
-- generated_at: 2025-12-29T13:53:28.787Z

create procedure dbo.sa_truncate_trace_data()
begin
  truncate table dbo.sa_tmp_diagnostic_connection;
  truncate table dbo.sa_tmp_diagnostic_statement;
  truncate table dbo.sa_tmp_diagnostic_query;
  truncate table dbo.sa_tmp_diagnostic_cursor;
  truncate table dbo.sa_tmp_diagnostic_request;
  truncate table dbo.sa_tmp_diagnostic_blocking;
  truncate table dbo.sa_tmp_diagnostic_deadlock;
  truncate table dbo.sa_tmp_diagnostic_hostvariable;
  truncate table dbo.sa_tmp_diagnostic_internalvariable;
  truncate table dbo.sa_tmp_diagnostic_cachecontents;
  truncate table dbo.sa_tmp_diagnostic_statistics;
  truncate table dbo.sa_tmp_diagnostic_optblock;
  truncate table dbo.sa_tmp_diagnostic_optjoinstrategy;
  truncate table dbo.sa_tmp_diagnostic_optquantifier;
  truncate table dbo.sa_tmp_diagnostic_optorder;
  truncate table dbo.sa_tmp_diagnostic_optrewrite
end
