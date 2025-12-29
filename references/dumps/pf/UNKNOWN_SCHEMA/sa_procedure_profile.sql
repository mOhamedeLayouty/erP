-- PF: UNKNOWN_SCHEMA.sa_procedure_profile
-- proc_id: 186
-- generated_at: 2025-12-29T13:53:28.746Z

create procedure dbo.sa_procedure_profile( 
  in filename long varchar default null,
  in save_to_file integer default 0 ) 
result( 
  object_type char(1),
  object_name char(128),
  owner_name char(128),
  table_name char(128),
  line_num unsigned integer,
  executions unsigned integer,
  millisecs unsigned integer,
  percentage double,
  foreign_owner char(128),
  foreign_table char(128) ) dynamic result sets 1
begin
  declare local temporary table ProcProfile(
    object_type char(1) not null,
    object_name char(128) not null,
    owner_name char(128) not null,
    table_name char(128) null,
    line_num unsigned integer not null,
    executions unsigned integer not null,
    millisecs unsigned integer not null,
    percentage double not null,
    foreign_owner char(128) null,
    foreign_table char(128) null,
    ) in SYSTEM not transactional;
  if filename is not null and save_to_file = 0 then
    load into table ProcProfile using file filename
  else
    call dbo.sa_internal_procedure_profile()
  end if;
  if filename is not null and save_to_file = 1 then
    unload from table ProcProfile into file filename
  end if;
  select * from ProcProfile
end
