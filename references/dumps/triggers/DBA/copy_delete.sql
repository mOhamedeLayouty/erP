-- TRIGGER: DBA.copy_delete
-- ON TABLE: DBA.doc_son_rec
-- generated_at: 2025-12-29T13:52:33.688Z

create trigger copy_delete.copy_delete after delete order 1 on
DBA.doc_son_rec
referencing old as old_name
for each row
//V1.1 delete details 
//V1.1 add delete user
begin
  insert into doc_son_rec_deleted( doc_t_num,
    doc_num,doc_type,doc_date,doc_tot_type,
    hld_code,acc_rec,manual_num,chqu_date,chqu_num,
    chqu_name,curr_id,curr_rate,curr_sub_tot,doc_tot,
    doc_rem,usr,rec_led,hld_acc,status_id,acc_type,
    conf_flage,conf_user,customer_flag,bank_flag,
    rec_num,company_code,station_code,car_code,
    cost_no,post_flag,resp,resp_user,
    log_store,bank_withdraw_date,
    bank_withdraw,pay_type_serial,
    delete_user,delete_date,delete_time ) values
    ( old_name.doc_t_num,old_name.doc_num,old_name.doc_type,old_name.doc_date,
    old_name.doc_tot_type,old_name.hld_code,old_name.acc_rec,old_name.manual_num,
    old_name.chqu_date,old_name.chqu_num,old_name.chqu_name,old_name.curr_id,
    old_name.curr_rate,old_name.curr_sub_tot,old_name.doc_tot,old_name.doc_rem,
    old_name.usr,old_name.rec_led,old_name.hld_acc,old_name.status_id,old_name.acc_type,
    old_name.conf_flage,old_name.conf_user,old_name.customer_flag,old_name.bank_flag,
    old_name.rec_num,old_name.company_code,old_name.station_code,old_name.car_code,
    old_name.cost_no,old_name.post_flag,old_name.resp,old_name.resp_user,
    old_name.log_store,old_name.bank_withdraw_date,old_name.bank_withdraw,
    old_name.pay_type_serial,old_name.edit_user,GETDATE(),Now() ) ;
  //
  delete from doc_son_rec_details
    where(old_name.doc_t_num = doc_son_rec_details.doc_t_num)
    and(old_name.doc_type = doc_son_rec_details.doc_type)
    and(old_name.service_center = doc_son_rec_details.service_center)
    and(old_name.location_id = doc_son_rec_details.location_id)
end
