-- TRIGGER: HR.update attendance
-- ON TABLE: HR.checkinout
-- generated_at: 2025-12-29T13:52:33.696Z

create trigger "update attendance" after insert order 1 on
hr.CHECKINOUT
referencing old as Old_row new as New_row
for each row
//V1.0 Created
//V1.1 handling error in insert if row exist
//V1.2 add first in and last out
begin
  declare @att_from time;
  declare @att_to time;
  if
    not exists(select 1 from hr.attendance
      where hr.attendance.emp_code = (select badgenumber from hr.USERINFO where userid = New_row.userid)
      and hr.attendance.att_date = "date"(New_row.checktime)) then
    insert into hr.attendance( att_date,
      emp_code,
      attended,
      att_from,
      att_to ) values
      ( "date"(New_row.checktime),
      (select badgenumber from hr.USERINFO where userid = New_row.userid),
      1,
      New_row.checktime,
      null ) 
  else
    select hr.attendance.att_from,hr.attendance.att_to into @att_from,@att_to
      from hr.attendance
      where hr.attendance.emp_code = (select badgenumber from hr.USERINFO where userid = New_row.userid)
      and hr.attendance.att_date = "date"(New_row.checktime);
    if(@att_from is null or convert(time,New_row.checktime) < convert(time,@att_from)) and New_row.checktype = 'I' then
      update hr.attendance set att_from = New_row.checktime,attended = 1
        where hr.attendance.emp_code = (select badgenumber from hr.USERINFO where userid = New_row.userid)
        and hr.attendance.att_date = "date"(New_row.checktime)
    end if;
    //
    if(@att_to is null or convert(time,New_row.checktime) > convert(time,@att_to)) and New_row.checktype = 'O' then
      update hr.attendance set att_to = New_row.checktime,attended = 1
        where hr.attendance.emp_code = (select badgenumber from hr.USERINFO where userid = New_row.userid)
        and hr.attendance.att_date = "date"(New_row.checktime)
    end if
  end if
end
