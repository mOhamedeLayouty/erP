-- TRIGGER: DBA.tu_checks
-- ON TABLE: DBA.checks
-- generated_at: 2025-12-29T13:52:33.684Z

create trigger tu_checks after update on DBA.Checks
referencing old as old_st new as new_st
for each row
//V1.1 add user id 
begin atomic
  if update(status) or update(current_location) or update(current_location_type) then
    insert into checks_transaction( trans_type,
      check_id,
      trans_from,
      trans_to,
      module,
      brand,
      service_center,
      trans_from_type,
      trans_to_type,
      check_num,
      trans_date,
      payment_value,trans_user ) values
      ( new_st.status,
      new_st.check_id,
      old_st.current_location,
      new_st.current_location,
      new_st.module,
      new_st.brand,
      new_st.service_center,
      old_st.current_location_type,
      new_st.current_location_type,
      new_st.check_num,
      today(),
      isnull(new_st.payment_value,0)-isnull(old_st.payment_value,0),new_st.user_id ) 
  end if
end
