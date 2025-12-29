-- PF: UNKNOWN_SCHEMA.sa_load_cost_model
-- proc_id: 84
-- generated_at: 2025-12-29T13:53:28.715Z

create procedure dbo.sa_load_cost_model( 
  in file_name char(1024) ) 
begin
  declare local temporary table LoadCostModelData(
    stat_id unsigned integer not null,
    group_id unsigned integer not null,
    format_id smallint not null,
    data long binary null,
    ) in SYSTEM on commit preserve rows;
  load into table LoadCostModelData using file file_name;
  call dbo.sa_internal_load_cost_model('LoadCostModelData')
end
