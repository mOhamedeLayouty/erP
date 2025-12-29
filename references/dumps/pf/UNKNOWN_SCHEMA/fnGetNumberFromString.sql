-- PF: UNKNOWN_SCHEMA.fnGetNumberFromString
-- proc_id: 449
-- generated_at: 2025-12-29T13:53:28.821Z

create function dba.fnGetNumberFromString( @strInput varchar(255) ) 
returns varchar(255)
as
begin
  declare @intNumber integer
  set @intNumber = PATINDEX('%[^0-9]%',@strInput)
  while @intNumber > 0
    begin
      set @strInput = STUFF(@strInput,@intNumber,1,'')
      set @intNumber = PATINDEX('%[^0-9]%',@strInput)
    end
  return ISNULL(@strInput,0)
end
