-- PF: UNKNOWN_SCHEMA.sa_virtual_sysindex
-- proc_id: 203
-- generated_at: 2025-12-29T13:53:28.751Z

create procedure dbo.sa_virtual_sysindex()
result( table_id unsigned integer,
  index_id unsigned integer,
  object_id unsigned integer,
  root unsigned integer,
  file_id unsigned smallint,
  "unique" char(1),
  creator unsigned smallint,
  index_name char(128),
  remarks long varchar,
  hash_limit unsigned smallint,
  disabled unsigned smallint ) dynamic result sets 1
begin
  declare local temporary table VirtualSysIndex(
    table_id unsigned integer not null,
    index_id unsigned integer not null,
    object_id unsigned integer not null,
    root unsigned integer null,
    file_id unsigned smallint null,
    "unique" char(1) null,
    creator unsigned smallint null,
    index_name char(128) null,
    remarks long varchar null,
    hash_limit unsigned smallint null,
    disabled unsigned smallint null,
    ) in SYSTEM not transactional;
  call dbo.sa_internal_virtual_sysindex();
  select * from VirtualSysIndex
end
