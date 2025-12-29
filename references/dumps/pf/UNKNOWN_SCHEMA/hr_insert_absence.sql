-- PF: UNKNOWN_SCHEMA.hr_insert_absence
-- proc_id: 442
-- generated_at: 2025-12-29T13:53:28.820Z

create procedure HR.hr_insert_absence()
//V2 prevent repeated
//V2.1 Handling missed days
begin
  declare @emp_code char(50);
  declare @date date = DATEADD(month,-2,today());
  declare err_notfound exception for sqlstate value '02000';
  declare cur_all dynamic scroll cursor for select distinct dbs_s_employe.emp_code as emp_code from dbs_s_employe
      where not dbs_s_employe.emp_code = any(select dbs_s_employe.emp_code from dbs_s_employe
        where(dbs_s_employe.emp_end_hir_date < @date));
  while @date < today() loop
    //if(select count(1) from hr.attendance where att_date = @date) > 0 then
    open cur_all;
    MyLoop: loop
      fetch next cur_all into @emp_code;
      if sqlstate = err_notfound or @emp_code is null then
        leave MyLoop
      end if;
      if(select count(1) from hr.attendance where att_date = @date and emp_code = @emp_code) < 1 then
        insert into attendance
          ( att_date,
          emp_code,
          attended,
          att_from,
          att_to,
          shift2_attended,
          shift3_attended,
          shift2_att_from,
          shift3_att_from,
          shift2_att_to,
          shift3_att_to ) values
          ( @date,
          @emp_code,
          0,
          null,
          null,
          0,
          0,
          null,
          null,
          null,
          null ) 
      else
      end if
    end loop MyLoop;
    close cur_all;
    //  else
    // end if;
    set @date = DATEADD(day,1,@date)
  end loop
end
