-- TRIGGER: DBA.tr_fill_depreciation
-- ON TABLE: DBA.fx_item_depreciation
-- generated_at: 2025-12-29T13:52:33.692Z

create trigger tr_fill_depreciation after insert order 1 on
DBA.fx_item_depreciation
referencing new as new_name
for each row /* WHEN( search_condition ) */
begin
  /* Type the trigger statements here */
  declare li_Index integer;
  declare ldc_Dep decimal;
  declare li_Days integer;
  declare li_Year integer;
  declare li_Month integer;
  set li_Index = 1;
  if new_name.notes = 'Partial First Year' then
    set li_Month = Month(new_name.part_date);
    set ldc_Dep = new_name.depreciation/(12-li_Month+1);
    set li_Index = li_Month;
    while li_Month <= 12 loop
      set li_Year = YEARS(new_name.part_date);
      set li_Days = f_days_month(li_Year,li_Month);
      insert into DBA.fx_item_depreciation_detail
        ( asset_code,
        branch_id,
        line_code,
        date_ending,
        depreciation,
        notes,
        posted ) values
        ( new_name.asset_code,
        new_name.branch_id,
        li_Index,
        "Date"(str(li_Year)+'-'+str(li_Month)+'-'+str(li_Days)),
        ldc_Dep,
        '',
        'N' ) ;
      set li_Index = li_Index+1;
      set li_Month = li_Month+1
    end loop
  elseif new_name.notes = 'Whole Year' then
    set ldc_Dep = new_name.depreciation/12;
    while li_Index <= 12 loop
      set li_Year = YEARS(new_name.date_ending);
      set li_Days = f_days_month(li_Year,li_Index);
      insert into DBA.fx_item_depreciation_detail
        ( asset_code,
        branch_id,
        line_code,
        date_ending,
        depreciation,
        notes,
        posted ) values
        ( new_name.asset_code,
        new_name.branch_id,
        li_Index,
        "Date"(str(li_Year)+'-'+str(li_Index)+'-'+str(li_Days)),
        ldc_Dep,
        '',
        'N' ) ;
      set li_Index = li_Index+1
    end loop
  elseif new_name.notes = 'Partial Last Year' then
    set li_Month = Month(new_name.part_date);
    set ldc_Dep = new_name.depreciation/li_Month;
    while li_Index <= li_Month loop
      set li_Year = YEARS(new_name.part_date);
      set li_Days = f_days_month(li_Year,li_Index);
      insert into DBA.fx_item_depreciation_detail
        ( asset_code,
        branch_id,
        line_code,
        date_ending,
        depreciation,
        notes,
        posted ) values
        ( new_name.asset_code,
        new_name.branch_id,
        li_Index,
        "Date"(str(li_Year)+'-'+str(li_Index)+'-'+str(li_Days)),
        ldc_Dep,
        '',
        'N' ) ;
      set li_Index = li_Index+1
    end loop
  end if
end
