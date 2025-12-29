-- PF: UNKNOWN_SCHEMA.sp_jdbc_escapeliteralforlike
-- proc_id: 329
-- generated_at: 2025-12-29T13:53:28.788Z

create procedure dbo.sp_jdbc_escapeliteralforlike( 
  @pString varchar(255) output ) 
as
declare @newString varchar(255)
declare @validEscapes varchar(255)
declare @escapeChar varchar(10)
declare @pIndex integer
declare @pLength integer
declare @curChar char(1)
declare @escapeIndex integer
declare @escapeLength integer
declare @boolEscapeIt integer
select @pLength = length(@pString)
if(@pString is null) or(@pLength = 0)
  begin
    return
  end
declare @work_to_do integer
select
  @work_to_do = locate(@pString,'%')
  +locate(@pString,'_')
  +locate(@pString,'\\')
  +locate(@pString,'[')
  +locate(@pString,']')
if @work_to_do = 0
  return
select @escapeChar = '\\'
select @validEscapes = '%_\\[]'
select @escapeLength = length(@validEscapes)
select @pIndex = 1
select @newString = ''
while(@pIndex <= @pLength)
  begin
    select @curChar = substring(@pString,@pIndex,1)
    select @escapeIndex = 1
    select @boolEscapeIt = 0
    while(@escapeIndex <= @escapeLength)
      begin
        if(substring(@validEscapes,@escapeIndex,1)
           = @curChar)
          begin
            select @boolEscapeIt = 1
            break
          end
        select @escapeIndex = @escapeIndex+1
      end
    if(@boolEscapeIt = 1)
      begin
        select @newString = @newString+@escapeChar+@curChar
      end
    else
      begin
        select @newString = @newString+@curChar
      end
    select @pIndex = @pIndex+1
  end
select @pString = ltrim(rtrim(@newString))
