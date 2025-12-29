-- PF: UNKNOWN_SCHEMA.sp_jdbc_convert_datatype
-- proc_id: 338
-- generated_at: 2025-12-29T13:53:28.790Z

create procedure dbo.sp_jdbc_convert_datatype( 
  @source integer,
  @destination integer ) 
as
select @source = @source+7
if(@source > 90)
  select @source = @source-82
if(@destination > 90)
  select @destination = @destination-82
select @destination = @destination+8
if((select substring(conversion,@destination,1)
    from dbo.spt_jdbc_conversion where datatype = @source) = '1')
  select 1
else
  select 0
