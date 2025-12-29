-- PF: UNKNOWN_SCHEMA.f_credit_return
-- proc_id: 371
-- generated_at: 2025-12-29T13:53:28.799Z

create function DBA.f_credit_return( in an_credit integer,in an_center integer,in an_location integer )  /* @parameter_name parameter_type [= default_value], ... */
returns numeric(20,7)
begin
  declare an_amount numeric(20,7);
  /* Type the function statements here */
  select sum(sc_debit_detail.price*sc_debit_detail.qty)
    into an_amount from sc_debit_detail
      ,sc_debit_header
    where(sc_debit_detail.debit_header = sc_debit_header.debit_header)
    and(sc_debit_header.service_center = sc_debit_detail.service_center)
    and(sc_debit_header.location_id = sc_debit_detail.location_id)
    and((sc_debit_header.credit_manual_number = an_credit)
    and(sc_debit_header.service_center = an_center)
    and(sc_debit_header.location_id = an_location)
    and(sc_debit_header.trans_id = 3));
  set an_amount = IsNull(an_amount,0);
  return an_amount
end
