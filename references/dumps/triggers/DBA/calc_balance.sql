-- TRIGGER: DBA.calc_balance
-- ON TABLE: DBA.sc_balance
-- generated_at: 2025-12-29T13:52:33.691Z

create trigger calc_balance after update of balance order 1 on
DBA.sc_balance
referencing old as old_balance new as new_balance
for each row
begin
  // month balance table variables
  declare mb_store_id integer;
  declare mb_item_id char(10);
  declare mb_date date;
  declare mb_credit numeric; //integer
  declare mb_debit numeric; //integer
  declare mb_rate numeric;
  declare mb_balance numeric;
  // balance table variables
  declare b_store_id integer;
  declare b_item_id char(10);
  declare b_balance numeric;
  // var
  declare bal numeric;
  declare old_bal numeric;
  declare new_bal numeric;
  declare d_date date;
  declare pre_date date;
  declare str varchar(10);
  declare str2 varchar(10);
  declare y integer;
  declare m integer;
  declare pre_y integer;
  declare pre_m integer;
  declare pre_bal numeric;
  set y = year(ToDay());
  set m = month(ToDay());
  set str = String(y,'-',m,'-',1);
  set d_date = "Date"(str);
  //calc pre date
  if m-1 = 0 then
    set pre_m = 12;
    set pre_y = y-1
  else
    set pre_m = m-1;
    set pre_y = y
  end if;
  set str2 = String(pre_y,'-',pre_m,'-',1);
  set pre_date = "Date"(str2);
  // Get Item & Store
  select item_id into b_item_id from DBA.sc_balance where item_id = new_balance.item_id and service_center = new_balance.service_center and store_id = new_balance.store_id and location_id = new_balance.location_id;
  select store_id into b_store_id from DBA.sc_balance where item_id = new_balance.item_id and service_center = new_balance.service_center and store_id = new_balance.store_id and location_id = new_balance.location_id;
  //Get pre balance
  set pre_bal = 0;
  select balance into pre_bal from DBA.sc_month_balance where item_id = b_item_id and service_center = new_balance.service_center and store_id = b_store_id and year(b_date) = year(pre_date) and month(b_date) = month(pre_date) and location_id = new_balance.location_id;
  //Get Old Balance
  //select balance into old_bal from DBA.sc_balance where item_id = old_balance.item_id and store_id = old_balance.store_id;
  set old_bal = old_balance.balance;
  // Get New Balance
  select balance into new_bal from DBA.sc_balance where item_id = new_balance.item_id and service_center = new_balance.service_center and store_id = new_balance.store_id and location_id = new_balance.location_id;
  // set new_bal=new_balance.balance;
  set bal = old_bal-new_bal;
  if not exists(select store_id into mb_store_id from DBA.sc_month_balance where store_id = b_store_id and item_id = b_item_id and service_center = new_balance.service_center and year(b_date) = year(today()) and month(b_date) = month(today()) and location_id = new_balance.location_id) then
    set mb_store_id = b_store_id;
    set mb_item_id = b_item_id;
    if bal > 0 then
      set mb_debit = bal;
      set mb_credit = 0
    else
      set mb_credit = -bal;
      set mb_debit = 0
    end if;
    set mb_balance = new_bal;
    select balance into pre_bal from DBA.sc_month_balance where item_id = b_item_id and service_center = new_balance.service_center
      and store_id = b_store_id and year(b_date) = year(pre_date) and month(b_date) = month(pre_date) and location_id = new_balance.location_id;
    if pre_bal > 0 then
      set mb_rate = mb_debit/pre_bal
    else
      set mb_rate = 0
    end if;
    insert into DBA.sc_month_balance( store_id,b_date,item_id,credit,debit,balance,rate,service_center,location_id ) values( mb_store_id,d_date,mb_item_id,mb_credit,mb_debit,mb_balance,mb_rate,new_balance.service_center,new_balance.location_id ) 
  else
    select store_id into mb_store_id from DBA.sc_month_balance where store_id = b_store_id and item_id = b_item_id and service_center = new_balance.service_center and year(b_date) = year(today()) and month(b_date) = month(today()) and location_id = new_balance.location_id;
    set mb_item_id = b_item_id;
    select credit into mb_credit from DBA.sc_month_balance where store_id = b_store_id and item_id = b_item_id and service_center = new_balance.service_center and year(b_date) = year(today()) and month(b_date) = month(today()) and location_id = new_balance.location_id;
    select debit into mb_debit from DBA.sc_month_balance where store_id = b_store_id and item_id = b_item_id and service_center = new_balance.service_center and year(b_date) = year(today()) and month(b_date) = month(today()) and location_id = new_balance.location_id;
    set mb_rate = 0;
    if bal > 0 then
      set mb_debit = mb_debit+bal
    else
      set mb_credit = -bal+mb_credit
    end if;
    set mb_balance = new_bal;
    select balance into pre_bal from DBA.sc_month_balance where item_id = mb_item_id and service_center = new_balance.service_center and store_id = mb_store_id and year(b_date) = year(pre_date) and month(b_date) = month(pre_date) and location_id = new_balance.location_id;
    if pre_bal > 0 then
      set mb_rate = mb_debit/pre_bal
    else
      set mb_rate = 0
    end if;
    update DBA.sc_month_balance set sc_month_balance.credit = mb_credit,sc_month_balance.debit = mb_debit,sc_month_balance.balance = mb_balance,sc_month_balance.rate = mb_rate where sc_month_balance.store_id = mb_store_id and sc_month_balance.item_id = mb_item_id and sc_month_balance.service_center = new_balance.service_center and year(sc_month_balance.b_date) = year(d_date) and month(sc_month_balance.b_date) = month(d_date) and sc_month_balance.location_id = new_balance.location_id
  end if
end
