-- PF: UNKNOWN_SCHEMA.sa_convert_timestamp_to_ml_progress
-- proc_id: 247
-- generated_at: 2025-12-29T13:53:28.764Z

create function dbo.sa_convert_timestamp_to_ml_progress( 
  in t1 timestamp ) 
returns unsigned bigint
begin
  declare ret unsigned bigint;
  select cast(datediff(day,'1900-01-01 00:00:00.000',t1) as unsigned bigint)
    *24*60*60*1000+datediff(millisecond,"date"(t1),t1)
    into ret;
  return ret
end
