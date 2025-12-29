-- PF: UNKNOWN_SCHEMA.sa_virtual_sysixcol
-- proc_id: 201
-- generated_at: 2025-12-29T13:53:28.751Z

create procedure dbo.sa_virtual_sysixcol()
result( table_id unsigned integer,
  index_id unsigned integer,
  sequence unsigned smallint,
  column_id unsigned integer,
  "order" char(1) ) dynamic result sets 1
begin
  declare local temporary table VirtualSysIxCol(
    table_id unsigned integer null,
    index_id unsigned integer null,
    sequence unsigned smallint null,
    column_id unsigned integer null,
    "order" char(1) null,
    ) in SYSTEM not transactional;
  call sa_internal_virtual_sysixcol();
  select * from VirtualSysIxCol
end
