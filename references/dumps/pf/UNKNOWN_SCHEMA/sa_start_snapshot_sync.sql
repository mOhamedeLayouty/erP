-- PF: UNKNOWN_SCHEMA.sa_start_snapshot_sync
-- proc_id: 181
-- generated_at: 2025-12-29T13:53:28.744Z

create procedure dbo.sa_start_snapshot_sync( 
  out sync_time timestamp ) 
begin
  commit work;
  call internal_sa_start_snapshot_sync(sync_time)
end
