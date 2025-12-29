-- PF: UNKNOWN_SCHEMA.f_get_item_reserved_qty
-- proc_id: 450
-- generated_at: 2025-12-29T13:53:28.822Z

create function DBA.f_get_item_reserved_qty( in as_item varchar(50),in an_center integer,in an_location integer,in an_store integer,in as_transId nvarchar(10) default '0' )  /* @parameter_name parameter_type [= default_value], ... */
returns numeric(20,7)
begin
  declare ldc_flag char(1);
  declare ldc_qty decimal(20,7);
  declare ldc_wsReservationQty decimal(20,7);
  declare ldc_wsReceiptionQty decimal(20,7);
  declare ldc_scQuotationQty decimal(20,7);
  //
  select f_get_about('sc_qty_reserved') into ldc_flag;
  if ldc_flag <> 'Y' then
    return 0
  end if;
  //1 WS Reservation
  select Sum(ws_reservationoperationitem.qty)
    into ldc_wsReservationQty from ws_reservation,ws_reservationoperationitem
    where(ws_reservation.reservationid = ws_reservationoperationitem.reservationid)
    and(ws_reservation.service_center = ws_reservationoperationitem.service_center)
    and(ws_reservation.location_id = ws_reservationoperationitem.location_id)
    and(ws_reservation.delete_flag <> 'Y')
    and(ws_reservation.reserve_date >= today())
    and(ws_reservation.status = 'R')
    and(ws_reservation.service_center = an_center)
    and(ws_reservation.location_id = an_location)
    and(ws_reservationoperationitem.itemid = as_item);
  //
  if ldc_wsReservationQty is null then
    set ldc_wsReservationQty = 0
  end if;
  //2 WS Reciption
  if ldc_wsReceiptionQty is null then
    set ldc_wsReceiptionQty = 0
  end if;
  //3 SC Quotation
  select Sum(sc_quotation_detail.qty)
    into ldc_scQuotationQty from sc_quotation_detail,sc_quotation_header
    where(sc_quotation_detail.debit_header = sc_quotation_header.debit_header)
    and(sc_quotation_detail.service_center = sc_quotation_header.service_center)
    and(sc_quotation_detail.location_id = sc_quotation_header.location_id)
    and(sc_quotation_header.service_center = an_center)
    and(sc_quotation_header.location_id = an_location)
    and(sc_quotation_detail.item_id = as_item)
    and(sc_quotation_header.status in( 'A','P' ) )
    and(sc_quotation_header.qty_reserved = 1)
    and(sc_quotation_header.confirm_date >= today())
    and(sc_quotation_detail.debit_header <> as_transId)
    and(not sc_quotation_header.debit_header = any(select distinct quotation_no from DBA.sc_debit_header where service_center = sc_quotation_header.service_center and location_id = sc_quotation_header.location_id and quotation_no is not null));
  //
  if ldc_scQuotationQty is null then
    set ldc_scQuotationQty = 0
  end if;
  //
  set ldc_qty = ldc_wsReservationQty+ldc_wsReceiptionQty+ldc_scQuotationQty;
  //
  return ldc_qty
end
