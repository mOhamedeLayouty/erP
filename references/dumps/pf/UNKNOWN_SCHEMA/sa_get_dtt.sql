-- PF: UNKNOWN_SCHEMA.sa_get_dtt
-- proc_id: 87
-- generated_at: 2025-12-29T13:53:28.716Z

create procedure dbo.sa_get_dtt( 
  in file_id unsigned smallint ) 
result( 
  BandSize unsigned integer,
  ReadTime unsigned integer,
  WriteTime unsigned integer ) dynamic result sets 1
begin
  declare local temporary table DTTTable(
    BandSize unsigned integer null,
    ReadTime unsigned integer null,
    WriteTime unsigned integer null,
    ) in SYSTEM not transactional;
  call dbo.sa_internal_get_dtt(file_id);
  select * from DTTTable order by BandSize asc
end
