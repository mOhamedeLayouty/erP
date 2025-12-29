-- PF: UNKNOWN_SCHEMA.f_get_collective_vacation
-- proc_id: 410
-- generated_at: 2025-12-29T13:53:28.810Z

create function HR.f_get_collective_vacation( in an_emp_code integer,in an_year integer,in an_type integer )  /* [IN] parameter_name parameter_type [DEFAULT default_value], ... */
returns integer
deterministic
begin
  declare return_num integer;
  declare count_vacation integer;
  declare li_temp integer;
  declare li_attendance integer;
  declare li_count integer;
  declare li_day_off integer;
  declare li_num_days integer;
  declare li_p_type_off integer;
  declare li_p_type integer;
  declare ls_serial char(50);
  declare ld_from_date date;
  declare ld_to_date date;
  set return_num = 0;
  set li_count = 1;
  select count() into count_vacation from emp_collective_vacation;
  while li_count <= count_vacation loop
    select p_serial,num_days into ls_serial,li_num_days from emp_collective_vacation where approved = 1 and delete_flag = 'N'
      and year(from_date) = an_year and p_serial = li_count;
    if ls_serial <> 0 then
      select from_date,to_date,p_type into ld_from_date,ld_to_date,li_p_type from emp_collective_vacation,dbs_s_employe where approved = 1 and delete_flag = 'N' and p_serial = li_count and emp_collective_vacation.from_date between dbs_s_employe.emp_hir_date
        and isnull(dbs_s_employe.emp_end_hir_date,today(),dbs_s_employe.emp_end_hir_date) and dbs_s_employe.emp_code = an_emp_code;
      select Count() into li_attendance from attendance where emp_code = an_emp_code and att_date = ld_from_date and attended = 1;
      if li_attendance = 0 then
        select first 1,p_type into li_day_off,li_p_type_off from emp_days_off where approved = 1 and delete_flag = 'N' and year(from_date) = an_year
          and emp_code = an_emp_code and(ld_from_date between from_date and to_date or ld_to_date between from_date and to_date);
        if li_day_off = 1 and(li_p_type_off = 1 or li_p_type_off = 3) and an_type = li_p_type then
          set return_num = return_num+li_num_days
        end if
      elseif ls_serial = li_count and an_type = li_p_type then set return_num = return_num+li_num_days
      end if end if;
    set li_count = li_count+1
  end loop;
  return return_num
end
