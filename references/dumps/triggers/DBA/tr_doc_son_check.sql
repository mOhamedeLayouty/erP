-- TRIGGER: DBA.tr_doc_son_check
-- ON TABLE: DBA.doc_son_rec
-- generated_at: 2025-12-29T13:52:33.687Z

create trigger tr_doc_son_check after insert,delete,update order 1 on
DBA.doc_son_rec
referencing old as old_rec new as new_rec
for each row
//v1.1 customer
//V1.2
//V1.3 get vendor id depend on account number and invoice
//V1.4 Add vendor id to the table "checks" by adding it here and in procedure "DBA.insert_update_delete_check"
begin
  declare ar_optype char(1);
  declare ar_check_type char(1);
  declare ar_cust_id varchar(50);
  declare ar_vend_code varchar(10);
  if new_rec.customer_flag = 'C' or old_rec.customer_flag = 'C' then
    if inserting then
      set ar_optype = 'I'
    elseif deleting then
      set ar_optype = 'D'
    elseif updating then
      set ar_optype = 'U'
    end if;
    if old_rec.customer_flag = 'C' and new_rec.customer_flag <> 'C' then
      set ar_optype = 'D'
    elseif old_rec.customer_flag <> 'C' and new_rec.customer_flag = 'C' then
      set ar_optype = 'I'
    end if;
    if new_rec.doc_type = '2' then
      //Add to Cash 
      set ar_check_type = 'R'; //�����
      set ar_cust_id = new_rec.customer_id;
      if ar_cust_id = null or ar_cust_id = '' then
        if new_rec.invoiceno <> null then
          set ar_cust_id = (select first CustomerID from DBA.ws_InvoiceHeader
              where invoiceno = new_rec.invoiceno
              and service_center = new_rec.service_center
              and location_id = new_rec.location_id)
        end if end if;
      if ar_cust_id = null or ar_cust_id = '' then
        if new_rec.doc_detail_type = 1 then //1 safe ,2 customers
          set ar_cust_id = (select first customer_id from Customer where acc_no = new_rec.hld_code)
        //Pull from Cash
        //
        end if
      end if
    else set ar_check_type = 'P';
      if new_rec.vendor_payment = 1 then //pull on vendor invoice
        set ar_vend_code = new_rec.vend_code
      else //pull on customer invoice
        if new_rec.invoiceno is not null and new_rec.invoiceno <> '' then
          set ar_cust_id = (select first CustomerID from DBA.ws_InvoiceHeader
              where invoiceno = new_rec.invoiceno
              and service_center = new_rec.service_center
              and location_id = new_rec.location_id);
          if ar_cust_id = null or ar_cust_id = '' then
            set ar_cust_id = new_rec.customer_id
          end if end if;
        if new_rec.doc_detail_type = 1 and ar_cust_id = null then //1 safe ,2 customers
          set ar_cust_id = (select first customer_id from Customer where acc_no = new_rec.hld_code)
        end if end if end if;
    call DBA.insert_update_delete_check(
    ar_optype,
    'C', //C cash ,R recipt
    new_rec.chqu_num,
    new_rec.doc_date,
    new_rec.chqu_date,
    null,
    null,
    new_rec.service_center,
    new_rec.location_id,
    'WS',
    new_rec.doc_t_num,
    new_rec.doc_t_num,
    new_rec.doc_type,
    ar_cust_id, /*customer id*/
    new_rec.doc_tot,
    null,
    new_rec.acc_rec,
    new_rec.acc_rec,
    'N',
    0, /*ar_payment_value */
    'S',
    ar_check_type,
    new_rec.chqu_name,
    ar_vend_code)
  end if
end
