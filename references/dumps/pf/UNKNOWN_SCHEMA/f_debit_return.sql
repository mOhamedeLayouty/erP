-- PF: UNKNOWN_SCHEMA.f_debit_return
-- proc_id: 372
-- generated_at: 2025-12-29T13:53:28.799Z

create function DBA.f_debit_return( in an_debit integer,in an_center integer,in an_location integer )  /* @parameter_name parameter_type [= default_value], ... */
returns numeric(20,7)
begin
  declare an_amount numeric(20,7);
  /* Type the function statements here */
  select Sum(sc_ret_detail.qty*sc_ret_detail.price)
    into an_amount from sc_ret_detail
      ,sc_ret_header
    where(sc_ret_detail.credit_header = sc_ret_header.credit_header)
    and(sc_ret_header.service_center = sc_ret_detail.service_center)
    and(sc_ret_header.location_id = sc_ret_detail.location_id)
    and(sc_ret_header.debit_header = an_debit)
    and(sc_ret_header.service_center = an_center)
    and(sc_ret_header.location_id = an_location);
  set an_amount = IsNull(an_amount,0);
  return an_amount
end
