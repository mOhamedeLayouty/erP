-- PF: UNKNOWN_SCHEMA.f_get_item_intransfer_qty
-- proc_id: 444
-- generated_at: 2025-12-29T13:53:28.820Z

create function DBA.f_get_item_intransfer_qty( in as_item varchar(50),in an_center integer,in an_location integer,in an_store integer ) 
returns numeric(20,7)
//V1.1 Beta
begin
  declare @trans_qty numeric(20,3);
  //
  select Sum(sc_transfer_detail.qty)
    into @trans_qty from sc_transfer_detail
      ,sc_transfer_header
    where(sc_transfer_header.credit_header = sc_transfer_detail.credit_header)
    and(sc_transfer_header.service_center = sc_transfer_detail.service_center)
    and(sc_transfer_header.location_id = sc_transfer_detail.location_id)
    and((sc_transfer_header.arrival_flag <> 'Y')
    and(sc_transfer_header.service_center = an_center)
    and(sc_transfer_header.location_id_to = an_location)
    and(sc_transfer_header.store_id_to = an_store)
    and(sc_transfer_detail.item_id = as_item));
  //
  /* Select sum( trans_qty) into @trans_qty 
from DBA.sc_items_transaction where 
(item_id = as_item )
and(sc_items_transaction.center_id = an_center)
and(sc_items_transaction.location_id_to = an_location)
and(sc_items_transaction.store_id_to = an_store)
and(arrival_flag='N') ; */
  //
  if @trans_qty is null then
    set @trans_qty = 0
  end if;
  return @trans_qty
end
