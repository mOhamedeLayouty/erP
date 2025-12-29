-- PF: UNKNOWN_SCHEMA.sa_convert_ml_progress_to_timestamp
-- proc_id: 248
-- generated_at: 2025-12-29T13:53:28.764Z

create function dbo.sa_convert_ml_progress_to_timestamp( 
  in progress unsigned bigint ) 
returns timestamp
begin
  declare ret timestamp;
  set ret = dateadd(day,progress/(24*60*60*1000),'1900-01-01');
  set ret = dateadd(millisecond,mod(progress,24*60*60*1000),ret);
  return ret
end
