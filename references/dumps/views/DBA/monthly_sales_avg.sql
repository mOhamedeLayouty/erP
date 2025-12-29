-- VIEW: DBA.monthly_sales_avg
-- generated_at: 2025-12-29T14:36:30.546Z
-- object_id: 14075
-- table_id: 1411
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.monthly_sales_avg
  as select sc_month_balance.item_id,
    sc_month_balance.service_center,
    sc_month_balance.location_id,
    Sum(sc_month_balance.debit) as all_out,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 1 and sc_month_balance.service_center = a.service_center) as Jan_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 2 and sc_month_balance.service_center = a.service_center) as Feb_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 3 and sc_month_balance.service_center = a.service_center) as Mar_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 4 and sc_month_balance.service_center = a.service_center) as Apr_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 5 and sc_month_balance.service_center = a.service_center) as May_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 6 and sc_month_balance.service_center = a.service_center) as Jun_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 7 and sc_month_balance.service_center = a.service_center) as Jul_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 8 and sc_month_balance.service_center = a.service_center) as Aug_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 9 and sc_month_balance.service_center = a.service_center) as Sep_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 10 and sc_month_balance.service_center = a.service_center) as Oct_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 11 and sc_month_balance.service_center = a.service_center) as Nov_sales,
    (select Sum(a.debit)/(case all_out when 0 then 1 else all_out end) from DBA.sc_month_balance as a where a.item_id = sc_month_balance.item_id and Year(a.b_date) = Year(Getdate()) and month(a.b_date) = 12 and sc_month_balance.service_center = a.service_center) as Dec_sales
    from DBA.sc_month_balance
    where Year(sc_month_balance.b_date) = Year(Getdate())
    group by sc_month_balance.item_id,
    sc_month_balance.service_center,
    sc_month_balance.location_id
