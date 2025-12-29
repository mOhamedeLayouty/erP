-- PF: UNKNOWN_SCHEMA.sa_disk_free_space
-- proc_id: 196
-- generated_at: 2025-12-29T13:53:28.749Z

create procedure dbo.sa_disk_free_space( 
  in p_dbspace_name varchar(128) default null ) 
result( 
  dbspace_name varchar(128),
  free_space unsigned bigint,
  total_space unsigned bigint ) dynamic result sets 1
begin
  declare local temporary table DiskFreeSpaceTable(
    dbspace_name varchar(128) null,
    free_space unsigned bigint null,
    file_num integer null,
    total_space unsigned bigint null,
    ) in SYSTEM not transactional;
  declare pick varchar(30);
  call dbo.sa_internal_disk_free_space();
  if(p_dbspace_name is null) then
    select dbspace_name,free_space,total_space from DiskFreeSpaceTable
      order by file_num asc
  elseif not exists(select * from DiskFreeSpaceTable where dbspace_name
     = p_dbspace_name) then
    if UPPER(p_dbspace_name) in( 'LOG','_LOG' ) then
      set pick = 'translog'
    elseif UPPER(p_dbspace_name) in( 'MIRROR','_MIRROR' ) then
      set pick = 'TRANSACTION LOG MIRROR'
    elseif UPPER(p_dbspace_name) in( 'TEMP','_TEMP' ) then
      set pick = 'temporary'
    else
      set pick = p_dbspace_name
    end if;
    select first dbspace_name,free_space,total_space from DiskFreeSpaceTable
      where UPPER(dbspace_name) = pick and file_num > 12
      order by file_num asc
  else
    select first dbspace_name,free_space,total_space from DiskFreeSpaceTable
      where dbspace_name = p_dbspace_name
      order by file_num asc
  end if
end
