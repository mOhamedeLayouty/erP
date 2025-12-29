-- TRIGGER: DBA.tr_ws_Eqpt_Category_parent
-- ON TABLE: DBA.ws_eqpt_category_parent
-- generated_at: 2025-12-29T13:52:33.694Z

create trigger tr_ws_Eqpt_Category_parent after insert,delete,update order 1 on
DBA.ws_eqpt_category_parent
referencing old as old_name new as new_name
for each row
/* WHEN( search_condition ) */
begin
  if inserting and(select my_val from DBA.about where code = 'car_active') <> 'Y' then
    insert into ws_eqpt_category
      ( category_id,
      description_a,
      description_e,
      parent_id,
      priceperhour,
      user_id,
      entry_date,
      catalogid,
      categorytype,
      chassisno,
      vol_vag_flag,
      priceperhour_service,
      priceperhour_warranty,
      service_center,
      vehicle_make,
      vehicle_model,
      category_price,
      descr,
      descr_a,
      engine,
      brand,
      traffic_description,
      priceperhour_bodypaint ) values
      ( new_name.category_id,
      new_name.description_a,
      new_name.description_e,
      new_name.category_id,
      new_name.priceperhour,
      new_name.user_id,
      new_name.entry_date,
      new_name.catalogid,
      new_name.categorytype,
      new_name.chassisno,
      new_name.vol_vag_flag,
      new_name.priceperhour_service,
      new_name.priceperhour_warranty,
      new_name.service_center,
      new_name.vehicle_make,
      new_name.vehicle_model,
      new_name.category_price,
      new_name.descr,
      new_name.descr_a,
      new_name.engine,
      new_name.brand,
      new_name.traffic_description,
      new_name.priceperhour_bodypaint ) 
  end if;
  //---------------------------------------------------------------------------------------------------------
  if updating and(select my_val from DBA.about where code = 'car_active') <> 'Y' then
    update ws_eqpt_category
      set description_a = new_name.description_a,
      description_e = new_name.description_e,
      priceperhour = new_name.priceperhour,
      user_id = new_name.user_id,
      entry_date = new_name.entry_date,
      catalogid = new_name.catalogid,
      categorytype = new_name.categorytype,
      chassisno = new_name.chassisno,
      vol_vag_flag = new_name.vol_vag_flag,
      priceperhour_service = new_name.priceperhour_service,
      priceperhour_warranty = new_name.priceperhour_warranty,
      vehicle_make = new_name.vehicle_make,
      vehicle_model = new_name.vehicle_model,
      category_price = new_name.category_price,
      descr = new_name.descr,
      descr_a = new_name.descr_a,
      engine = new_name.engine,
      brand = new_name.brand,
      traffic_description = new_name.traffic_description,
      priceperhour_bodypaint = new_name.priceperhour_bodypaint
      where ws_eqpt_category.parent_id = new_name.category_id
      and ws_eqpt_category.service_center = new_name.service_center
  end if;
  //----------------------------------------------------------------------------------------------------------------
  if updating and(select my_val from DBA.about where code = 'car_active') = 'Y' then
    update ws_eqpt_category
      set catalogid = new_name.catalogid,
      priceperhour = new_name.priceperhour,
      priceperhour_service = new_name.priceperhour_service,
      priceperhour_warranty = new_name.priceperhour_warranty,
      priceperhour_bodypaint = new_name.priceperhour_bodypaint
      where ws_eqpt_category.parent_id = new_name.category_id
      and ws_eqpt_category.service_center = new_name.service_center
  end if
end
