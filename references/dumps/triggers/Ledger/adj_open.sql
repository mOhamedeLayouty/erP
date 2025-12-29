-- TRIGGER: Ledger.adj_open
-- ON TABLE: Ledger.rep_led_info
-- generated_at: 2025-12-29T13:52:33.695Z

create trigger Ledger.adj_open after insert order 1 on
Ledger.rep_led_info
referencing new as new_data
for each row
begin
  declare no_bj integer;
  declare acc_no char(60);
  declare old_db numeric;
  declare old_cr numeric;
  declare new_db numeric;
  declare new_cr numeric;
  set new_db = new_data.debit;
  set new_cr = new_data.credit;
  if new_data.note = 'Z-OPEN-B' then
    if exists(select rep_led_info.debit into old_db from rep_led_info where rep_led_info.note = 'Z-BE-FOR' and rep_led_info.acc_no = new_data.acc_no) then
      select rep_led_info.debit into old_db from rep_led_info where rep_led_info.note = 'Z-BE-FOR' and rep_led_info.acc_no = new_data.acc_no;
      select rep_led_info.credit into old_cr from rep_led_info where rep_led_info.note = 'Z-BE-FOR' and rep_led_info.acc_no = new_data.acc_no;
      set new_db = isnull(new_db,0,new_db);
      set new_cr = isnull(new_cr,0,new_cr);
      set old_db = isnull(old_db,0,old_db);
      set old_cr = isnull(old_cr,0,old_cr);
      set new_db = new_db+old_db;
      set new_cr = new_cr+old_cr;
      update rep_led_info set rep_led_info.debit = new_db,rep_led_info.credit = new_cr where rep_led_info.note = 'Z-BE-FOR' and rep_led_info.acc_no = new_data.acc_no;
      delete from rep_led_info where rep_led_info.note = 'Z-OPEN-B' and rep_led_info.acc_no = new_data.acc_no
    end if
  elseif new_data.note = 'Z-BE-FOR' then
    if exists(select rep_led_info.debit into old_db from rep_led_info where rep_led_info.note = 'Z-OPEN-B' and rep_led_info.acc_no = new_data.acc_no) then
      select rep_led_info.debit into old_db from rep_led_info where rep_led_info.note = 'Z-OPEN-B' and rep_led_info.acc_no = new_data.acc_no;
      select rep_led_info.credit into old_cr from rep_led_info where rep_led_info.note = 'Z-OPEN-B' and rep_led_info.acc_no = new_data.acc_no;
      set new_db = isnull(new_db,0.0,new_db);
      set new_cr = isnull(new_cr,0.0,new_cr);
      set old_db = isnull(old_db,0.0,old_db);
      set old_cr = isnull(old_cr,0.0,old_cr);
      set new_db = new_db+old_db;
      set new_cr = new_cr+old_cr;
      update rep_led_info set rep_led_info.debit = new_db,rep_led_info.credit = new_cr where rep_led_info.note = 'Z-BE-FOR' and rep_led_info.acc_no = new_data.acc_no;
      delete from rep_led_info where rep_led_info.note = 'Z-OPEN-B' and rep_led_info.acc_no = new_data.acc_no
    end if
  end if
end
