-- PF: UNKNOWN_SCHEMA.sa_table_page_usage
-- proc_id: 74
-- generated_at: 2025-12-29T13:53:28.713Z

create procedure dbo.sa_table_page_usage()
result( 
  TableId unsigned integer,
  TablePages integer,
  PctUsedT integer,
  IndexPages integer,
  PctUsedI integer,
  PctOfFile integer,
  TableName char(128) ) dynamic result sets 1
begin
  declare local temporary table PageUse(
    TableId unsigned integer null,
    TablePages integer null,
    PctUsedT integer null,
    IndexPages integer null,
    PctUsedI integer null,
    PctOfFile integer null,
    TableName char(128) null,
    ) in SYSTEM not transactional;
  call dbo.sa_internal_table_page_usage();
  select * from PageUse order by TableID asc
end
