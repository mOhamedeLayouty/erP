-- PF: UNKNOWN_SCHEMA.of_MonthName_arabic
-- proc_id: 362
-- generated_at: 2025-12-29T13:53:28.797Z

create function DBA.of_MonthName_arabic( in an_daynumber integer ) 
returns varchar(15)
begin
  declare as_dayname varchar(15);
  case an_daynumber when 1 then
    set as_dayname = '01 - �����' when 2 then
    set as_dayname = '02 - ������' when 3 then
    set as_dayname = '03 - ����' when 4 then
    set as_dayname = '04 - �����' when 5 then
    set as_dayname = '05 - ����' when 6 then
    set as_dayname = '06 - �����' when 7 then
    set as_dayname = '07 - �����' when 8 then
    set as_dayname = '08 - �����' when 9 then
    set as_dayname = '09 - ������' when 10 then
    set as_dayname = '10 - ������' when 11 then
    set as_dayname = '11 - ������' when 12 then
    set as_dayname = '12 - ������'
  end case;
  return(as_dayname)
end
