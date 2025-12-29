-- PF: UNKNOWN_SCHEMA.calc_items_values
-- proc_id: 422
-- generated_at: 2025-12-29T13:53:28.813Z

create procedure DBA.calc_items_values()
//V2 prevent repeated
//V3 done year by year
begin
  declare @item_id char(50);
  declare @center_id integer;
  declare @location_id integer;
  declare @fyear integer;
  declare @tyear integer;
  declare @ldate date;
  declare @cdate date;
  declare @fdate date;
  declare @tdate date;
  declare err_notfound exception for sqlstate value '02000';
  declare cur_all dynamic scroll cursor for select distinct sc_balance.item_id as item_id,
      sc_balance.service_center as center_id from sc_balance;
  /*select distinct item_id as item_id,service_center as center_id from sc_debit_detail;*/
  open cur_all;
  select "date"(my_val) into @ldate from DBA.about where DBA.about.code = 'month_date';
  if @ldate is null then
    set @ldate = "date"('1900-01-01')
  end if;
  set @cdate = "date"(today());
  MyLoop: loop
    fetch next cur_all into @item_id,@center_id;
    if sqlstate = err_notfound or @item_id is null then
      leave MyLoop
    end if;
    set @fyear = year(@ldate);
    set @tyear = year(@cdate); //current date
    while @fyear <= @tyear loop
      set @fdate = YMD(@fyear,1,1);
      if @fyear = @tyear then
        set @tdate = @cdate
      else
        set @tdate = YMD(@fyear+1,1,1)
      end if;
      select DBA.get_item_qty(@item_id,@center_id,@fdate,@tdate) into @location_id;
      //Other values required to calc for the item  
      set @fyear = @fyear+1
    end loop
  end loop MyLoop;
  close cur_all
end
