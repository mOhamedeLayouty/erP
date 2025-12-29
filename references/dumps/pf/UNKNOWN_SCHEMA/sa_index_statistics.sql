-- PF: UNKNOWN_SCHEMA.sa_index_statistics
-- proc_id: 72
-- generated_at: 2025-12-29T13:53:28.712Z

create procedure dbo.sa_index_statistics()
result( 
  TableId unsigned integer,
  TableName char(128),
  IndexId unsigned integer,
  IndexName char(128),
  Cardinality double,
  KeyCount double,
  LeafPageCount double,
  Depth unsigned integer,
  HashLength unsigned integer ) dynamic result sets 1
begin
  declare local temporary table IndexStats(
    TableId unsigned integer null,
    TableName char(128) null,
    IndexId unsigned integer null,
    IndexName char(128) null,
    Cardinality double null,
    KeyCount double null,
    LeafPageCount double null,
    Depth unsigned integer null,
    HashLength unsigned integer null,
    ) in SYSTEM not transactional;
  call dbo.sa_internal_index_statistics();
  select * from IndexStats order by TableId asc,IndexId asc
end
