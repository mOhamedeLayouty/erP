-- VIEW: DBA.v_kpi_monthly
-- generated_at: 2025-12-29T14:36:30.558Z
-- object_id: 14273
-- table_id: 1426
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.v_kpi_monthly /* view_column_name, ... */
  as select distinct
    kpi_monthly.year,
    kpi_monthly.month,
    kpi_monthly.service_center,
    kpi_monthly.location_id,
    //---------------------Number counts-------------------------------
    convert(decimal,kpi_monthly.ws_no_reservation),
    convert(decimal,kpi_monthly.ws_no_ro),
    convert(decimal,kpi_monthly.ws_no_jo),
    //-----------------------Sold FLat Rate------------------------------
    kpi_monthly.sold_all_fru,
    kpi_monthly.sold_c_fru,
    kpi_monthly.sold_g_fru,
    //--------------------------------Working Hours---------------------------------
    kpi_monthly.w_all_hrs,
    kpi_monthly.w_c_hrs,
    kpi_monthly.w_g_hrs,
    //-----------------------OverTime------------------------------------------
    kpi_monthly.overtime_hrs,
    //----------------------------Paid Hour-----------------------------------------
    kpi_monthly.paid_hrs,
    //------------------------no_technicians--------------------------------------------------------
    (select distinct count(hr.dbs_s_employe.emp_code)
      from hr.dbs_s_employe
      where(hr.dbs_s_employe.dep_code = 14) and(
      (year(hr.dbs_s_employe.emp_end_hir_date) > kpi_monthly.year and month(hr.dbs_s_employe.emp_end_hir_date) > kpi_monthly.month) or
      hr.dbs_s_employe.emp_end_hir_date is null) and(
      hr.dbs_s_employe.service_center = kpi_monthly.service_center or hr.dbs_s_employe.all_centers = 1)
      and hr.dbs_s_employe.emp_code = any(select hr.dbs_s_employe.emp_code
        from hr.dbs_s_employe
        where(hr.dbs_s_employe.empcode is not null) and(
        hr.dbs_s_employe.empcode <> ''))) as no_technicians,
    //------------------------Totals--------------------------------------------------------
    (kpi_monthly.ws_no_reservation/(case kpi_monthly.ws_no_ro when 0 then 1 else kpi_monthly.ws_no_ro end)) as appo_rate,
    (kpi_monthly.paid_hrs+kpi_monthly.overtime_hrs) as avail_hrs,
    (kpi_monthly.sold_all_fru/(case kpi_monthly.ws_no_ro when 0 then 1 else kpi_monthly.ws_no_ro end)) as sold_all_fru_RO,
    (kpi_monthly.w_all_hrs/10*(case avail_hrs when 0 then 1 else avail_hrs end)) as bay_utiliz_rate, ///10(from about) *monthly hours worked
    (kpi_monthly.ws_no_ro/(case no_technicians when 0 then 1 else no_technicians end)) as unit_serviced_TS,
    (kpi_monthly.sold_all_fru/(case no_technicians when 0 then 1 else no_technicians end)) as sold_all_fru_TS,
    (kpi_monthly.sold_all_fru/(case avail_hrs when 0 then 1 else avail_hrs end)) as service_productivity,
    (kpi_monthly.sold_all_fru/(case kpi_monthly.w_all_hrs when 0 then 1 else kpi_monthly.w_all_hrs end)) as labor_efficiency,
    (kpi_monthly.w_all_hrs/(case avail_hrs when 0 then 1 else avail_hrs end)) as labor_utilization,
    //===================================================================================
    //Second Satge
    //-----------------------no of car-------------------------------
    convert(decimal,kpi_monthly.car_in_no),
    convert(decimal,kpi_monthly.car_out_no),
    //----------------------sparepart sales----------------------------------
    kpi_monthly.parts_cust_sales,
    kpi_monthly.parts_WS_sales,
    kpi_monthly.parts_wrty_sales,
    //--------------------------Out Service------------------------------------
    kpi_monthly.outservice_wrty_sales,
    kpi_monthly.outservice_WS_sales,
    //----------------------------Labor---------------------------------------
    kpi_monthly.labor_cust_sales,
    kpi_monthly.labor_wrty_sales,
    //---------------------------Discount-----------------------------------
    kpi_monthly.DicountLabor,
    kpi_monthly.DicountItem,
    //----------------------------Collection----------------------------------
    kpi_monthly.collection,
    //-------------------------------Totals------------------------------------------------------------
    (kpi_monthly.parts_cust_sales+kpi_monthly.parts_WS_sales+kpi_monthly.parts_wrty_sales) as parts_all_sales,
    (kpi_monthly.outservice_wrty_sales+kpi_monthly.outservice_WS_sales) as outservice_all_sales,
    (kpi_monthly.labor_cust_sales+kpi_monthly.labor_wrty_sales) as labor_all_sales,
    (kpi_monthly.DicountLabor+kpi_monthly.DicountItem) as allDiscount,
    (kpi_monthly.parts_cust_sales+kpi_monthly.parts_WS_sales+kpi_monthly.parts_wrty_sales+kpi_monthly.outservice_wrty_sales+kpi_monthly.labor_wrty_sales) as total_sales_revenue
    from DBA.kpi_monthly
    order by kpi_monthly.year asc,kpi_monthly.month asc
