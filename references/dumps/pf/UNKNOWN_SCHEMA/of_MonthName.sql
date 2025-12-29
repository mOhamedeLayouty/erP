-- PF: UNKNOWN_SCHEMA.of_MonthName
-- proc_id: 363
-- generated_at: 2025-12-29T13:53:28.797Z

create function DBA.of_MonthName( in an_daynumber integer ) 
returns varchar(15)
begin
  declare as_dayname varchar(15);
  case an_daynumber when 1 then
    set as_dayname = '01 - January' when 2 then
    set as_dayname = '02 - February' when 3 then
    set as_dayname = '03 - March' when 4 then
    set as_dayname = '04 - April' when 5 then
    set as_dayname = '05 - May' when 6 then
    set as_dayname = '06 - June' when 7 then
    set as_dayname = '07 - July' when 8 then
    set as_dayname = '08 - August' when 9 then
    set as_dayname = '09 - September' when 10 then
    set as_dayname = '10 - October' when 11 then
    set as_dayname = '11 - November' when 12 then
    set as_dayname = '12 - December'
  end case;
  return(as_dayname)
end
