-- PF: UNKNOWN_SCHEMA.f_get_item_cost_date
-- proc_id: 387
-- generated_at: 2025-12-29T13:53:28.804Z

create function DBA.f_get_item_cost_date( in as_item varchar(50),in an_center integer,in an_location integer,in an_store integer,in ad_date date default today(),in at_time time default now() )  /* @parameter_name parameter_type [= default_value], ... */
returns numeric(20,7)
//V1.1 Beta
//V1.2 get cost from open balance if no transaction
//V1.3 error handling
//V1.4 location_to
begin
  declare @item_cost numeric(20,3);
  declare @trans_cost numeric(20,3);
  declare @trans_type varchar(5);
  declare @avg_price numeric(20,3);
  declare @location_id integer;
  declare @location_id_to integer;
  declare @store_id integer;
  declare @store_id_to integer;
  select top 1 trans_cost,item_cost,trans_type,location_id,location_id_to,store_id,store_id_to
    into @trans_cost,@item_cost,@trans_type,@location_id,@location_id_to,@store_id,@store_id_to from DBA.sc_items_transaction
    where item_id = as_item
    and(sc_items_transaction.center_id = an_center)
    and((sc_items_transaction.location_id = an_location and sc_items_transaction.store_id = an_store)
    or(sc_items_transaction.location_id_to = an_location and sc_items_transaction.store_id_to = an_store))
    and(trans_date <= ad_date) order by trans_date+isnull(trans_time,now()) desc;
  /*
and(trans_date+isnull(trans_time,now()))
= (select max(trans_date+isnull(trans_time,now())) from DBA.sc_items_transaction
where item_id = as_item
and(sc_items_transaction.center_id = an_center)
and(sc_items_transaction.location_id = an_location or sc_items_transaction.location_id_to = an_location)
and(sc_items_transaction.store_id = an_store or sc_items_transaction.store_id_to = an_store)
and(trans_date <= ad_date));*/
  if @trans_type = 'DB' then
    set @avg_price = IsNull(@trans_cost,0)
  elseif @trans_type = 'INTr' and @location_id = an_location and @store_id = an_store then
    set @avg_price = IsNull(@trans_cost,0)
  elseif @trans_type = 'INTr' and @location_id_to = an_location and @store_id_to = an_store then
    set @avg_price = IsNull(@item_cost,0)
  elseif @trans_type = 'CR' then
    set @avg_price = IsNull(@item_cost,0)
  elseif @trans_type = 'RT' then
    set @avg_price = IsNull(@item_cost,0)
  end if;
  if @avg_price = 0 or @avg_price is null then
    select bg_price into @avg_price from DBA.sc_balance
      where item_id = as_item and service_center = an_center and location_id = an_location and store_id = an_store
      and bg_date <= ad_date
  end if;
  if @avg_price is null then
    set @avg_price = 0
  end if;
  return @avg_price
end
