-- PF: UNKNOWN_SCHEMA.SP_ServicedVehiclesSummaryReport
-- proc_id: 430
-- generated_at: 2025-12-29T13:53:28.816Z

create procedure DBA.SP_ServicedVehiclesSummaryReport( in @ad_date date default today(),in @an_center integer default 1,in @an_location integer default 0 )  /* [IN | OUT | INOUT] parameter_name parameter_type [DEFAULT default_value], ... */
/* RESULT( column_name column_type, ... ) */
begin
  select(select my_val from DBA.About where code = 'club_e') as Main,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.jobdate = @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarIn,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.jobdate = @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarIn_other,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.jobdate >= YMD(year(@ad_date),month(@ad_date),1))
      and(ws_joborder.jobdate <= @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarIn_month,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.jobdate >= YMD(year(@ad_date),month(@ad_date),1))
      and(ws_joborder.jobdate <= @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarIn_other_month,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.out_date = @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarOut,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.out_date = @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarOut_other,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.out_date >= YMD(year(@ad_date),month(@ad_date),1))
      and(ws_joborder.out_date <= @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarOut_month,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.out_date >= YMD(year(@ad_date),month(@ad_date),1))
      and(ws_joborder.out_date <= @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarOut_other_month,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(ws_joborder.jobdate = @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarWork,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(ws_joborder.jobdate = @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarWork_other,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(ws_joborder.jobdate >= YMD(year(@ad_date),month(@ad_date),1))
      and(ws_joborder.jobdate <= @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarWork_month,
    (select Count()
      from ws_joborder,ws_eqpt,ws_eqpt_category
      where(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(ws_joborder.jobdate >= YMD(year(@ad_date),month(@ad_date),1))
      and(ws_joborder.jobdate <= @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as CarWork_other_month,
    (select Count()
      from ws_joborder,ws_reception,ws_eqpt,ws_eqpt_category
      where(ws_reception.receptionid = ws_joborder.voucherid) and(ws_reception.service_center = ws_joborder.service_center) and(ws_reception.location_id = ws_joborder.location_id)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(convert(date,ws_reception.end_date) = @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as sd,
    (select Count()
      from ws_joborder,ws_reception,ws_eqpt,ws_eqpt_category
      where(ws_reception.receptionid = ws_joborder.voucherid) and(ws_reception.service_center = ws_joborder.service_center) and(ws_reception.location_id = ws_joborder.location_id)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(convert(date,ws_reception.end_date) = @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as sd_other,
    (select Count()
      from ws_joborder,ws_reception,ws_eqpt,ws_eqpt_category
      where(ws_reception.receptionid = ws_joborder.voucherid) and(ws_reception.service_center = ws_joborder.service_center) and(ws_reception.location_id = ws_joborder.location_id)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(convert(date,ws_reception.end_date) >= DATEADD(day,-3,@ad_date))
      and(convert(date,ws_reception.end_date) < @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as sd1_3,
    (select Count()
      from ws_joborder,ws_reception,ws_eqpt,ws_eqpt_category
      where(ws_reception.receptionid = ws_joborder.voucherid) and(ws_reception.service_center = ws_joborder.service_center) and(ws_reception.location_id = ws_joborder.location_id)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(convert(date,ws_reception.end_date) >= DATEADD(day,-3,@ad_date))
      and(convert(date,ws_reception.end_date) < @ad_date)
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as sd_1_3_other,
    (select Count()
      from ws_joborder,ws_reception,ws_eqpt,ws_eqpt_category
      where(ws_reception.receptionid = ws_joborder.voucherid) and(ws_reception.service_center = ws_joborder.service_center) and(ws_reception.location_id = ws_joborder.location_id)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(convert(date,ws_reception.end_date) >= DATEADD(day,-6,@ad_date))
      and(convert(date,ws_reception.end_date) < DATEADD(day,-3,@ad_date))
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as sd4_6,
    (select Count()
      from ws_joborder,ws_reception,ws_eqpt,ws_eqpt_category
      where(ws_reception.receptionid = ws_joborder.voucherid) and(ws_reception.service_center = ws_joborder.service_center) and(ws_reception.location_id = ws_joborder.location_id)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(convert(date,ws_reception.end_date) >= DATEADD(day,-6,@ad_date))
      and(convert(date,ws_reception.end_date) < DATEADD(day,-3,@ad_date))
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as sd_4_6_other,
    (select Count()
      from ws_joborder,ws_reception,ws_eqpt,ws_eqpt_category
      where(ws_reception.receptionid = ws_joborder.voucherid) and(ws_reception.service_center = ws_joborder.service_center) and(ws_reception.location_id = ws_joborder.location_id)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(convert(date,ws_reception.end_date) <= DATEADD(day,-7,@ad_date))
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand = 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as sd_7,
    (select Count()
      from ws_joborder,ws_reception,ws_eqpt,ws_eqpt_category
      where(ws_reception.receptionid = ws_joborder.voucherid) and(ws_reception.service_center = ws_joborder.service_center) and(ws_reception.location_id = ws_joborder.location_id)
      and(ws_eqpt_category.category_id = ws_eqpt.category_id) and(ws_eqpt_category.service_center = ws_eqpt.service_center)
      and(ws_joborder.eqptid = ws_eqpt.eqpt_id) and(ws_joborder.service_center = ws_eqpt.service_center)
      and(ws_joborder.OrderStatus <> 'C')
      and(convert(date,ws_reception.end_date) <= DATEADD(day,-7,@ad_date))
      and(ws_joborder.service_center = @an_center)
      and(ws_joborder.location_id = @an_location or @an_location = 0)
      and(ws_eqpt_category.main_brand <> 'Y')
      and(Isnull(ws_joborder.deleteflag,'N') = 'N')) as sd_7_other
end
