-- PF: UNKNOWN_SCHEMA.sa_text_index_stats
-- proc_id: 245
-- generated_at: 2025-12-29T13:53:28.763Z

create procedure dbo.sa_text_index_stats()
result( 
  owner_id unsigned integer,
  table_id unsigned integer,
  index_id unsigned integer,
  text_config_id unsigned bigint,
  owner_name char(128),
  table_name char(128),
  index_name char(128),
  text_config_name char(128),
  doc_count unsigned bigint,
  doc_length unsigned bigint,
  pending_length unsigned bigint,
  deleted_length unsigned bigint,
  last_refresh timestamp ) dynamic result sets 1
internal name 'sa_text_index_stats'
