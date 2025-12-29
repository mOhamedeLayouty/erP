-- PF: UNKNOWN_SCHEMA.f_car_existed_in_date
-- proc_id: 373
-- generated_at: 2025-12-29T13:53:28.800Z

create function DBA.f_car_existed_in_date( in as_vehicle_id varchar(10),in as_vin varchar(50),in al_store integer,in ad_Date date ) 
returns integer
begin
  declare is_avilable integer;
  declare my_vin varchar(50);
  declare my_store integer;
  declare my_date date;
  declare my_time time;
  declare my_type integer;
  declare err_notfound exception for sqlstate value '02000';
  declare cur_av dynamic scroll cursor for select v_vehicles_transactions.vin,
      v_vehicles_transactions.store_id,
      v_vehicles_transactions.credit_date,
      v_vehicles_transactions.trans_time,
      v_vehicles_transactions.trans_type
      from v_vehicles_transactions
      where v_vehicles_transactions.vehicle_id = as_vehicle_id
      and v_vehicles_transactions.vin = as_vin
      and v_vehicles_transactions.store_id = al_store
      and v_vehicles_transactions.credit_date <= ad_date
      order by v_vehicles_transactions.credit_date desc,
      v_vehicles_transactions.trans_time desc;
  open cur_av;
  MyLoop: loop
    fetch next cur_av into my_vin,my_store,my_date,my_time,my_type;
    if sqlstate = err_notfound then
      leave MyLoop
    end if;
    if my_date = ad_Date then
      set is_avilable = 1;
      leave MyLoop
    elseif my_date < ad_Date and my_type = 2 then
      set is_avilable = 0;
      leave MyLoop
    else
      set is_avilable = 1;
      leave MyLoop
    end if;
    leave MyLoop
  end loop MyLoop;
  close cur_av;
  return is_avilable
end
