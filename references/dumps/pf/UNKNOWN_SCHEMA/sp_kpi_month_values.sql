-- PF: UNKNOWN_SCHEMA.sp_kpi_month_values
-- proc_id: 436
-- generated_at: 2025-12-29T13:53:28.817Z

create procedure DBA.sp_kpi_month_values()
//
begin
  declare @kpi_code varchar(100);
  declare @last_date date;
  declare @fdate date;
  declare @tdate date;
  declare @fyear integer;
  declare @tyear integer;
  declare @fmonth integer;
  declare @tmonth integer;
  declare @smonth integer;
  declare @emonth integer;
  declare @syear integer;
  declare @year integer;
  declare @month integer;
  declare @kpi_value decimal(15,3);
  declare @ins varchar(100);
  declare @upd varchar(100);
  declare err_notfound exception for sqlstate value '02000';
  declare cur_all dynamic scroll cursor for select distinct kpi_calc_date.kpi_code as kpi_code,
      kpi_calc_date.last_date as last_date from kpi_calc_date where kpi_calc_date.need_calc = 'Y';
  open cur_all;
  MyLoop: loop
    fetch next cur_all into @kpi_code,@last_date;
    if sqlstate = err_notfound or @kpi_code is null then
      leave MyLoop
    end if;
    if @last_date is null then
      set @fdate = "date"('2005-01-01')
    else
      set @fdate = @last_date
    end if;
    set @tdate = "date"(today());
    set @fyear = year(@fdate);
    set @fmonth = month(@fdate);
    set @tyear = year(@tdate);
    set @tmonth = month(@tdate);
    set @syear = @fyear;
    while @syear <= @tyear loop //Year 
      if @fyear = @tyear then //one year
        set @smonth = @fmonth;
        set @emonth = @tmonth
      elseif @fyear <> @tyear and @syear <> @fyear and @syear <> @tyear then //internal year
        set @smonth = 1;
        set @emonth = 12
      elseif @fyear <> @tyear and @syear = @fyear and @syear <> @tyear then //first year
        set @smonth = @fmonth;
        set @emonth = 12
      elseif @fyear <> @tyear and @syear = @tyear then //last year
        set @smonth = 1;
        set @emonth = @tmonth
      else
        set @smonth = @fmonth;
        set @emonth = 12
      end if;
      while @smonth <= @emonth loop //Month
        set @year = @syear;
        set @month = @smonth;
        //-------------------------------------------- 
        //-----------Calc KPI------------------------
        for centers as curs insensitive cursor for //Centers
          select center_id
            from ws_centers_service do
          for locations as locs insensitive cursor for //Locations
            select location_id as ar_location
              from ws_center_location do
            select DBA.f_get_kpi_value(@kpi_code,@year,@month,center_id,ar_location) into @kpi_value;
            //[1]Table--> kpi_monthly_h
            if not exists(select * from kpi_monthly_h where kpi_code = @kpi_code and year = @year
                and service_center = center_id and location_id = ar_location) then
              execute immediate 'insert into kpi_monthly_h( kpi_code,year,service_center,location_id,m'
                 || @month || ') values(''' || @kpi_code || ''',' || @year || ','
                 || center_id || ',' || ar_location || ',' || @kpi_value || ');'
            else
              execute immediate('update kpi_monthly_h set m'+string(@month)+' = '+string(@kpi_value)+'where kpi_code='''+@kpi_code+'''and year ='
                +string(@year)+'and service_center ='+string(center_id)+'and location_id ='+string(ar_location))
            end if end for end for;
        //---------------------------------------------
        update kpi_calc_date set last_date = YMD(@year,@month,1) where kpi_code = @kpi_code;
        //--------------------------------------------- 
        set @smonth = @smonth+1
      end loop;
      set @syear = @syear+1
    end loop
  end loop MyLoop;
  close cur_all
end
