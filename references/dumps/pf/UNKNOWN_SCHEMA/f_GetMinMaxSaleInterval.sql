-- PF: UNKNOWN_SCHEMA.f_GetMinMaxSaleInterval
-- proc_id: 389
-- generated_at: 2025-12-29T13:53:28.804Z

create function DBA.f_GetMinMaxSaleInterval( 
  in as_item varchar(50),
  in fdate date,
  in tdate date,
  in MinMax varchar(3),
  in an_center integer,
  in an_location integer default 0,
  in an_store integer default 0 ) 
returns decimal(12,3)
begin
  declare ldc_min decimal(12,3);
  declare ldc_max decimal(12,3);
  declare ll_ret decimal(12,3);
  select isnull(max(qty_add-qty_sub),0),
    isnull(min(qty_add-qty_sub),0) into ldc_max,ldc_min
    from(select sc_debit_header.debit_date,
        sum(isnull(sc_debit_detail.qty,0)) as qty_add,
        isnull((select sum(isnull(sc_ret_detail.qty,0))
          from sc_ret_detail
            ,sc_ret_header
          where(sc_ret_detail.credit_header = sc_ret_header.credit_header)
          and(sc_ret_detail.service_center = sc_ret_header.service_center)
          and(sc_ret_detail.location_id = sc_ret_header.location_id)
          and(sc_ret_header.credit_date = sc_debit_header.debit_date)
          and(sc_ret_detail.item_id = sc_debit_detail.item_id)
          and(sc_ret_header.service_center = sc_debit_header.service_center)
          and(sc_ret_header.location_id = sc_debit_header.location_id)
          and(sc_ret_header.store_id = sc_debit_header.store_id)),0) as qty_sub
        from sc_debit_detail
          ,sc_debit_header
        where(sc_debit_detail.debit_header = sc_debit_header.debit_header)
        and(sc_debit_detail.service_center = sc_debit_header.service_center)
        and(sc_debit_detail.location_id = sc_debit_header.location_id)
        and(sc_debit_header.trans_id = 1)
        and(sc_debit_header.debit_date > fdate)
        and(sc_debit_header.debit_date <= tdate)
        and(sc_debit_detail.item_id = as_item)
        and(sc_debit_header.service_center = an_center)
        and(sc_debit_header.location_id = an_location or an_location = 0)
        and(sc_debit_header.store_id = an_store or an_store = 0)
        group by sc_debit_header.debit_date,sc_debit_detail.item_id,
        sc_debit_header.service_center,sc_debit_header.location_id,sc_debit_header.store_id
        order by debit_date asc) as t;
  if MinMax = 'min' then
    set ll_ret = ldc_min
  else
    set ll_ret = ldc_max
  end if;
  return ll_ret
end
