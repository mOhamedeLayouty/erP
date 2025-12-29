-- PF: UNKNOWN_SCHEMA.sc_auto_reorder_items_trail
-- proc_id: 419
-- generated_at: 2025-12-29T13:53:28.812Z

create procedure DBA.sc_auto_reorder_items_trail( @s_center integer )  /* [IN | OUT | INOUT] parameter_name parameter_type [DEFAULT default_value], ... */
--V2
as /* RESULT( column_name column_type, ... ) */
begin
  declare @rcount integer,
  @all_out numeric(30,12),@m1 numeric(30,12),@m2 numeric(30,12),@m3 numeric(30,12),@m4 numeric(30,12),@m5 numeric(30,12),
  @m6 numeric(30,12),@m7 numeric(30,12),@m8 numeric(30,12),
  @m9 numeric(30,12),@m10 numeric(30,12),@m11 numeric(30,12),@m12 numeric(30,12),@item varchar(50),
  @amount1 numeric(10,3),@amount2 numeric(10,3),@amount3 numeric(10,3),@amount4 numeric(10,3),@amount5 numeric(10,3),@amount6 numeric(10,3),
  @amount7 numeric(10,3),@amount8 numeric(10,3),@amount9 numeric(10,3),@amount10 numeric(10,3),@amount11 numeric(10,3),@amount12 numeric(10,3),
  @m1_p numeric(30,12),@m2_p numeric(30,12),@m3_p numeric(30,12),@m4_p numeric(30,12),@m5_p numeric(30,12),@m6_p numeric(30,12),
  @m7_p numeric(30,12),@m8_p numeric(30,12),@m9_p numeric(30,12),@m10_p numeric(30,12),@m11_p numeric(30,12),@m12_p numeric(30,12),
  @amount1_p numeric(10,3),@amount2_p numeric(10,3),@amount3_p numeric(10,3),@amount4_p numeric(10,3),@amount5_p numeric(10,3),@amount6_p numeric(10,3),
  @amount7_p numeric(10,3),@amount8_p numeric(10,3),@amount9_p numeric(10,3),@amount10_p numeric(10,3),@amount11_p numeric(10,3),@amount12_p numeric(10,3)
  select sc_auto_reorder.item_id,sc_auto_reorder.service_center,sc_auto_reorder.location_id,
    sc_auto_reorder.qty,sc_auto_reorder.price,sc_auto_reorder.chck,sc_auto_reorder.lost_qty,
    sc_auto_reorder.sold_qty,sc_auto_reorder.last_receive,sc_auto_reorder.last_sold,
    sc_auto_reorder.on_hand,sc_auto_reorder.vendor_price,sc_auto_reorder.back_order,
    sc_item.seasonal_item,sc_item.pmc,sc_auto_reorder.on_order,sc_item.weight,
    sc_item.qty_factor,sc_item.storage_cost,sc_auto_reorder.ord_factor,from_date,
    to_date,no_month,lead_time,safety_stock_time,description,SparePart,
    Jan_sales=1.1111111111111,Feb_sales=1.1111111111111,
    Mar_sales=1.1111111111111,Apr_sales=1.1111111111111,May_sales=1.1111111111111,
    Jun_sales=1.1111111111111,Jul_sales=1.1111111111111,Aug_sales=1.1111111111111,
    Sep_sales=1.1111111111111,Oct_sales=1.1111111111111,
    Nov_sales=1.1111111111111,Dec_sales=1.1111111111111,
    Jan_amount=1111111111.111,Feb_amount=1111111111.111,Mar_amount=1111111111.111,Apr_amount=1111111111.111,
    May_amount=1111111111.111,Jun_amount=1111111111.111,Jul_amount=1111111111.111,Aug_amount=1111111111.111,
    Sep_amount=1111111111.111,Oct_amount=1111111111.111,Nov_amount=1111111111.111,Dec_amount=1111111111.111,
    Jan_sales_p=1.1111111111111,Feb_sales_p=1.1111111111111,Mar_sales_p=1.1111111111111,Apr_sales_p=1.1111111111111,
    May_sales_p=1.1111111111111,Jun_sales_p=1.1111111111111,Jul_sales_p=1.1111111111111,Aug_sales_p=1.1111111111111,
    Sep_sales_p=1.1111111111111,Oct_sales_p=1.1111111111111,Nov_sales_p=1.1111111111111,Dec_sales_p=1.1111111111111,
    Jan_amount_p=1111111111.111,Feb_amount_p=1111111111.111,Mar_amount_p=1111111111.111,Apr_amount_p=1111111111.111,
    May_amount_p=1111111111.111,Jun_amount_p=1111111111.111,Jul_amount_p=1111111111.111,Aug_amount_p=1111111111.111,
    Sep_amount_p=1111111111.111,Oct_amount_p=1111111111.111,Nov_amount_p=1111111111.111,Dec_amount_p=1111111111.111
    into #t
    from sc_item,sc_auto_reorder where(sc_item.item_id = sc_auto_reorder.item_id)
    and(sc_item.service_center = sc_auto_reorder.service_center) and(qty > 0)
    and(sc_auto_reorder.service_center = @s_center)
    order by sc_item.sparepart asc
  set @rcount = @@rowcount
  select * into #t2 from #t
  set rowcount 1
  while(@rcount > 0)
    begin
      select @item = item_id from #t2
      set rowcount 0
      select @all_out = Sum(debit) from sc_month_balance
        where item_id = @item and service_center = @s_center
        and year(b_date) in( Year(Getdate())-1,Year(Getdate()) ) 
        group by item_id,service_center
      select @all_out = isnull(@all_out,1)
      select @amount1 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 1 and sc_month_balance.service_center = a.service_center),0.0),
        @amount2 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 2 and sc_month_balance.service_center = a.service_center),0.0),
        @amount3 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 3 and sc_month_balance.service_center = a.service_center),0.0),
        @amount4 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 4 and sc_month_balance.service_center = a.service_center),0.0),
        @amount5 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 5 and sc_month_balance.service_center = a.service_center),0.0),
        @amount6 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 6 and sc_month_balance.service_center = a.service_center),0.0),
        @amount7 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 7 and sc_month_balance.service_center = a.service_center),0.0),
        @amount8 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 8 and sc_month_balance.service_center = a.service_center),0.0),
        @amount9 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 9 and sc_month_balance.service_center = a.service_center),0.0),
        @amount10 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 10 and sc_month_balance.service_center = a.service_center),0.0),
        @amount11 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 11 and sc_month_balance.service_center = a.service_center),0.0),
        @amount12 = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 12 and sc_month_balance.service_center = a.service_center),0.0),
        @amount1_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 1 and sc_month_balance.service_center = a.service_center),0.0),
        @amount2_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 2 and sc_month_balance.service_center = a.service_center),0.0),
        @amount3_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 3 and sc_month_balance.service_center = a.service_center),0.0),
        @amount4_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 4 and sc_month_balance.service_center = a.service_center),0.0),
        @amount5_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 5 and sc_month_balance.service_center = a.service_center),0.0),
        @amount6_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 6 and sc_month_balance.service_center = a.service_center),0.0),
        @amount7_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 7 and sc_month_balance.service_center = a.service_center),0.0),
        @amount8_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 8 and sc_month_balance.service_center = a.service_center),0.0),
        @amount9_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 9 and sc_month_balance.service_center = a.service_center),0.0),
        @amount10_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 10 and sc_month_balance.service_center = a.service_center),0.0),
        @amount11_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 11 and sc_month_balance.service_center = a.service_center),0.0),
        @amount12_p = isnull((select Sum(a.debit) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate())-1 and month(a.b_date) = 12 and sc_month_balance.service_center = a.service_center),0.0)
        from sc_month_balance where sc_month_balance.item_id = @item and sc_month_balance.service_center = @s_center
        and Year(sc_month_balance.b_date) in( Year(Getdate()),Year(Getdate())-1 ) 
        group by sc_month_balance.item_id,sc_month_balance.service_center
      /* set @m1=@amount1/@all_out
set @m2=@amount2/@all_out
set @m3=@amount3/@all_out
set @m4=@amount4/@all_out
set @m5=@amount5/@all_out
set @m6=@amount6/@all_out
set @m7=@amount7/@all_out
set @m8=@amount8/@all_out
set @m9=@amount9/@all_out
set @m10=@amount10/@all_out
set @m11=@amount11/@all_out
set @m12=@amount12/@all_out
set @m1_p=@amount1_p/@all_out
set @m2_p=@amount2_p/@all_out
set @m3_p=@amount3_p/@all_out
set @m4_p=@amount4_p/@all_out
set @m5_p=@amount5_p/@all_out
set @m6_p=@amount6_p/@all_out
set @m7_p=@amount7_p/@all_out
set @m8_p=@amount8_p/@all_out
set @m9_p=@amount9_p/@all_out
set @m10_p=@amount10_p/@all_out
set @m11_p=@amount11_p/@all_out
set @m12_p=@amount12_p/@all_out */
      update #t
        set Jan_sales = @amount1/(case @all_out when 0 then 1 else @all_out end),
        Feb_sales = @amount2/(case @all_out when 0 then 1 else @all_out end),
        Mar_sales = @amount3/(case @all_out when 0 then 1 else @all_out end),
        Apr_sales = @amount4/(case @all_out when 0 then 1 else @all_out end),
        May_sales = @amount5/(case @all_out when 0 then 1 else @all_out end),
        Jun_sales = @amount6/(case @all_out when 0 then 1 else @all_out end),
        Jul_sales = @amount7/(case @all_out when 0 then 1 else @all_out end),
        Aug_sales = @amount8/(case @all_out when 0 then 1 else @all_out end),
        Sep_sales = @amount9/(case @all_out when 0 then 1 else @all_out end),
        Oct_sales = @amount10/(case @all_out when 0 then 1 else @all_out end),
        Nov_sales = @amount11/(case @all_out when 0 then 1 else @all_out end),
        Dec_sales = @amount12/(case @all_out when 0 then 1 else @all_out end),
        Jan_amount = @amount1,Feb_amount = @amount2,Mar_amount = @amount3,Apr_amount = @amount4,
        May_amount = @amount5,Jun_amount = @amount6,Jul_amount = @amount7,Aug_amount = @amount8,Sep_amount = @amount9,
        Oct_amount = @amount10,Nov_amount = @amount11,Dec_amount = @amount12,
        Jan_sales_p = @amount1_p/(case @all_out when 0 then 1 else @all_out end),
        Feb_sales_p = @amount2_p/(case @all_out when 0 then 1 else @all_out end),
        Mar_sales_p = @amount3_p/(case @all_out when 0 then 1 else @all_out end),
        Apr_sales_p = @amount4_p/(case @all_out when 0 then 1 else @all_out end),
        May_sales_p = @amount5_p/(case @all_out when 0 then 1 else @all_out end),
        Jun_sales_p = @amount6_p/(case @all_out when 0 then 1 else @all_out end),
        Jul_sales_p = @amount7_p/(case @all_out when 0 then 1 else @all_out end),
        Aug_sales_p = @amount8_p/(case @all_out when 0 then 1 else @all_out end),
        Sep_sales_p = @amount9_p/(case @all_out when 0 then 1 else @all_out end),
        Oct_sales_p = @amount10_p/(case @all_out when 0 then 1 else @all_out end),
        Nov_sales_p = @amount11_p/(case @all_out when 0 then 1 else @all_out end),
        Dec_sales_p = @amount12_p/(case @all_out when 0 then 1 else @all_out end),
        Jan_amount_p = @amount1_p,Feb_amount_p = @amount2_p,Mar_amount_p = @amount3_p,Apr_amount_p = @amount4_p,
        May_amount_p = @amount5_p,Jun_amount_p = @amount6_p,Jul_amount_p = @amount7_p,Aug_amount_p = @amount8_p,
        Sep_amount_p = @amount9_p,Oct_amount_p = @amount10_p,Nov_amount_p = @amount11_p,Dec_amount_p = @amount12_p
        where item_id = @item
      set rowcount 1
      delete from #t2 where item_id = @item
      set @rcount = @rcount-1
    end
  set rowcount 0
  select * from #t
end
