-- PF: UNKNOWN_SCHEMA.sa_read_backup_history
-- proc_id: 145
-- generated_at: 2025-12-29T13:53:28.735Z

create procedure dbo.sa_read_backup_history()
result( backupOp varchar(2000) ) dynamic result sets 1
begin
  declare local temporary table BackupOps(
    linenum integer null,
    bkupop varchar(2000) null,
    ) in SYSTEM not transactional;
  call dbo.sa_internal_read_backup_history();
  select bkupop from BackupOps order by linenum asc
end
