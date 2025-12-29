-- PF: UNKNOWN_SCHEMA.calc_month_qty_all
-- proc_id: 423
-- generated_at: 2025-12-29T13:53:28.814Z

create procedure DBA.calc_month_qty_all()
//V2 prevent repeated
begin
  declare @item_id char(50);
  declare @center_id integer;
  declare @location_id integer;
  declare @fdate date;
  declare @tdate date;
  declare err_notfound exception for sqlstate value '02000';
  declare cur_all dynamic scroll cursor for select distinct sc_balance.item_id as item_id,
      sc_balance.service_center as center_id from sc_balance;
  open cur_all;
  select "date"(my_val) into @fdate from DBA.about where DBA.about.code = 'month_date';
  if @fdate is null then
    set @fdate = "date"('1900-01-01')
  end if;
  set @tdate = "date"(today());
  MyLoop: loop
    fetch next cur_all into @item_id,@center_id;
    if sqlstate = err_notfound or @item_id is null then
      leave MyLoop
    end if;
    select dba.calc_month_qty(@item_id,@center_id,@fdate,@tdate)
      into @location_id
  end loop MyLoop;
  close cur_all
end
