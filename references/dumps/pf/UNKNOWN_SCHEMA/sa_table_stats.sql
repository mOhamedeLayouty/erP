-- PF: UNKNOWN_SCHEMA.sa_table_stats
-- proc_id: 76
-- generated_at: 2025-12-29T13:53:28.713Z

create procedure dbo.sa_table_stats()
result( 
  table_id integer,
  creator char(128),
  table_name char(128),
  count unsigned bigint,
  table_page_count unsigned bigint,
  table_page_cached unsigned bigint,
  table_page_reads unsigned bigint,
  ext_page_count unsigned bigint,
  ext_page_cached unsigned bigint,
  ext_page_reads unsigned bigint ) dynamic result sets 1
begin
  declare local temporary table sa_table_stats_table(
    table_id integer not null,
    table_page_cached unsigned bigint null,
    table_page_reads unsigned bigint null,
    ext_page_cached unsigned bigint null,
    ext_page_reads unsigned bigint null,
    ) in SYSTEM not transactional;
  call dbo.sa_internal_table_stats();
  select T.table_id,U.user_name,T.table_name,
    T.count,
    T.table_page_count,
    S.table_page_cached,
    S.table_page_reads,
    T.ext_page_count,
    S.ext_page_cached,
    S.ext_page_reads
    from SYS.SYSTAB as T join SYS.SYSUSER as U
      on T.creator = U.user_id
      join sa_table_stats_table as S
      on T.table_id = S.table_id
end
