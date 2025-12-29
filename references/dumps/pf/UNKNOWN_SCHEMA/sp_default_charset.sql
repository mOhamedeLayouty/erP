-- PF: UNKNOWN_SCHEMA.sp_default_charset
-- proc_id: 349
-- generated_at: 2025-12-29T13:53:28.794Z

create procedure dbo.sp_default_charset
as
declare @default_collation char(128)
select @default_collation = default_collation from SYS.SYSINFO
if @default_collation is null
  begin
    select DEFAULT_CHARSET=charsetn from dbo.spt_collation_map where collation is null
  end
else
  begin
    select DEFAULT_CHARSET=charsetn from dbo.spt_collation_map
      where collation = @default_collation
  end
