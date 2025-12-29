-- TRIGGER: DBA.tr_Receipt_check
-- ON TABLE: DBA.ws_ReceiptDetail
-- generated_at: 2025-12-29T13:52:33.687Z

create trigger tr_Receipt_check after insert,delete,update order 1 on
DBA.ws_ReceiptDetail
referencing old as old_rec new as new_rec
for each row
begin
  declare ar_optype char(1);
  declare ar_check_type char(1);
  declare ar_cust_id varchar(50);
  if new_rec.paymenttype = 'C' then
    if inserting then
      set ar_optype = 'I'
    elseif deleting then
      set ar_optype = 'D'
    elseif updating then
      set ar_optype = 'U'
    end if;
    set ar_check_type = 'R'; //�����
    set ar_cust_id = (select custid from DBA.ws_Receipt
        where receipt_id = new_rec.receipt_id
        and service_center = new_rec.service_center
        and location_id = new_rec.location_id);
    call DBA.insert_update_delete_check(
    ar_optype,
    'R', //C cash ,R recipt
    new_rec.checkno,
    new_rec.paymentdate,
    new_rec.checkduedate,
    null,
    null,
    new_rec.service_center,
    new_rec.location_id,
    'WS',
    new_rec.ReceiptNo,
    null,
    null,
    ar_cust_id, /*customer id*/
    new_rec.paymentamount,
    null,
    new_rec.cash_id,
    new_rec.cash_id,
    'N',
    0, /*ar_payment_value */
    'S',
    ar_check_type,
    new_rec.bankname)
  end if
end
