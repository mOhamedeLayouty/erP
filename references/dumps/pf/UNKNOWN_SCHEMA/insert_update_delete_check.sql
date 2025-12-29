-- PF: UNKNOWN_SCHEMA.insert_update_delete_check
-- proc_id: 421
-- generated_at: 2025-12-29T13:53:28.813Z

create procedure DBA.insert_update_delete_check( 
  //V1.2 adding vendor id to "Checks" table
  //V1.3 convert integer to numeric
  //V1.4 get max as numeric
  ar_optype char(1),
  ar_type char(1),
  ar_check_num varchar(50),
  ar_issue_date date,
  ar_due_date date,
  ar_bank_id integer,
  ar_brand integer,
  ar_service_center integer,
  ar_location_id integer,
  ar_module varchar(10),
  ar_receipt_id varchar(10),
  ar_doc_t_num char(13),
  ar_doc_type char(2),
  ar_customer_id varchar(10),
  ar_check_value decimal(15,3),
  ar_log_store integer,
  ar_issue_location varchar(5),
  ar_current_location varchar(5),
  ar_status varchar(5),
  ar_payment_value decimal(15,3),
  ar_current_location_type varchar(5),
  ar_check_type char(1),
  ar_bank_name varchar(50),
  ar_vend_code varchar(10) default null ) 
begin
  declare ret integer;
  declare @serial numeric(20);
  if ar_optype = 'I' then
    select max(convert(numeric(20),checks.check_id)) into @serial from checks;
    if @serial < 1 or @serial is null then
      set @serial = 1
    else
      set @serial = @serial+1
    end if;
    insert into checks
      ( check_id,
      check_num,
      issue_date,
      due_date,
      bank_id,
      brand,
      service_center,
      location_id,
      module,
      receipt_id,
      doc_t_num,
      doc_type,
      customer_id,
      check_value,
      log_store,
      issue_location,
      current_location,
      status,
      payment_value,
      current_location_type,
      check_type,
      bank_name,
      vend_code ) values
      ( @serial,
      ar_check_num,
      ar_issue_date,
      ar_due_date,
      ar_bank_id,
      ar_brand,
      ar_service_center,
      ar_location_id,
      ar_module,
      ar_receipt_id,
      ar_doc_t_num,
      ar_doc_type,
      ar_customer_id,
      ar_check_value,
      ar_log_store,
      ar_issue_location,
      ar_current_location,
      ar_status,
      ar_payment_value,
      ar_current_location_type,
      ar_check_type,
      ar_bank_name,
      ar_vend_code ) 
  elseif ar_optype = 'U' then
    update checks
      set check_num = ar_check_num,
      issue_date = ar_issue_date,
      due_date = ar_due_date,
      bank_id = ar_bank_id,
      brand = ar_brand,
      service_center = ar_service_center,
      module = ar_module,
      receipt_id = ar_receipt_id,
      customer_id = ar_customer_id,
      check_value = ar_check_value,
      log_store = ar_log_store,
      issue_location = ar_issue_location,
      current_location = ar_current_location,
      status = ar_status,
      payment_value = ar_payment_value,
      current_location_type = ar_current_location_type,
      check_type = ar_check_type,
      bank_name = ar_bank_name,
      vend_code = ar_vend_code
      where doc_t_num = ar_doc_t_num
      and doc_type = ar_doc_type
      and service_center = ar_service_center
      and location_id = ar_location_id
  elseif ar_optype = 'D' then
    delete from checks where doc_t_num = ar_doc_t_num
      and doc_type = ar_doc_type
      and service_center = ar_service_center
      and location_id = ar_location_id
  end if
end
