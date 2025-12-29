-- PF: UNKNOWN_SCHEMA.sa_remove_index_consultant_analysis
-- proc_id: 208
-- generated_at: 2025-12-29T13:53:28.753Z

create procedure dbo.sa_remove_index_consultant_analysis( in master integer ) 
begin
  delete from dbo.ix_consultant_log where master_id = master;
  delete from dbo.ix_consultant_affected_columns where master_id = master;
  delete from dbo.ix_consultant_ixcol where master_id = master;
  delete from dbo.ix_consultant_query_index where master_id = master;
  delete from dbo.ix_consultant_index where master_id = master;
  delete from dbo.ix_consultant_query_phase where master_id = master;
  delete from dbo.ix_consultant_query_text where master_id = master;
  delete from dbo.ix_consultant_master where master_id = master
end
