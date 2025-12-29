-- PF: UNKNOWN_SCHEMA.f_getlastcredit
-- proc_id: 370
-- generated_at: 2025-12-29T13:53:28.799Z

create function DBA.f_getlastcredit( in aItemId varchar(50) )  /* [IN] parameter_name parameter_type [DEFAULT default_value], ... */
returns decimal
begin
  declare LastAdded date;
  declare Lastprice decimal;
  select max(sc_credit_header.credit_date) into LastAdded from sc_credit_detail,sc_credit_header where(sc_credit_detail.credit_header = sc_credit_header.credit_header) and(sc_credit_detail.item_id = aItemId);
  select distinct(sc_credit_detail.price) into Lastprice from sc_credit_detail,sc_credit_header where(sc_credit_detail.credit_header = sc_credit_header.credit_header) and(sc_credit_detail.item_id = aItemId) and(sc_credit_header.credit_date = LastAdded);
  return Lastprice
end
