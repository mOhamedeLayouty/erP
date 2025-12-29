-- VIEW: CRM.Opencalls
-- generated_at: 2025-12-29T14:36:30.510Z
-- object_id: 14180
-- table_id: 1421
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view CRM.Opencalls /* view_column_name, ... */
  as select count() from crm.customer where(customer.in_call = '0' and customer.busy = '0' and customer.wrong_number = '0') and(
    customer.status = 'A' and customer.call_status is null)
