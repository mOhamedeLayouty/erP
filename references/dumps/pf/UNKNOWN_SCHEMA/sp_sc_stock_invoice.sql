-- PF: UNKNOWN_SCHEMA.sp_sc_stock_invoice
-- proc_id: 447
-- generated_at: 2025-12-29T13:53:28.821Z

create procedure DBA.sp_sc_stock_invoice( 
  in @InvoiceID varchar(10),
  in @InvoiceType integer,
  in @service_center integer,
  in @location_id integer ) 
--Ver 1.0 first version
--Ver 1.1 add sc_quotation_id
--Ver 1.2 add sc_quotation_location_id
begin
  declare @invoice_nature varchar(1);
  declare @invoice_status varchar(1);
  declare @invoice_customerId varchar(50);
  declare @invoice_customer_name varchar(50);
  declare @invoice_user_id varchar(50);
  declare @invoice_salesman_id integer;
  declare @invoice_quotation_id integer;
  declare @invoice_quotation_location_id integer;
  declare @invoice_debit_header integer;
  declare @debit_header integer;
  declare @credit_header integer;
  declare @manual_number integer;
  declare @store_id integer;
  declare @itemid varchar(50);
  declare @qty numeric(10,3);
  declare @price numeric(10,3);
  declare @balance numeric(10,3);
  declare @newBalance numeric(10,3);
  declare @cost numeric(10,3);
  declare @newCost numeric(10,3);
  declare err_notfound exception for sqlstate value '02000';
  declare cursor_items dynamic scroll cursor for select itemid,qty,price from ws_invoicedetail
      where(ws_invoicedetail.invoiceid = @InvoiceID and ws_invoicedetail.invoicetype = @InvoiceType)
      and(ws_invoicedetail.service_center = @service_center and ws_invoicedetail.location_id = @location_id);
  --
  select store_id,invoice_nature,Status,CustomerID,customer_name,user_id,salesman_id,sc_quotation_id,sc_quotation_location_id,debit_header
    into @store_id,@invoice_nature,@invoice_status,@invoice_customerId,
    @invoice_customer_name,@invoice_user_id,@invoice_salesman_id,@invoice_quotation_id,@invoice_quotation_location_id,
    @invoice_debit_header from ws_invoiceheader
    where(invoiceid = @InvoiceID and invoicetype = @InvoiceType and service_center = @service_center and location_id = @location_id);
  --Debit Order
  if @invoice_nature = 'O' then
    select Max(debit_header) into @debit_header from sc_debit_header where(service_center = @service_center and location_id = @location_id);
    if @debit_header is null then
      set @debit_header = 1
    end if;
    set @debit_header = @debit_header+1;
    select Max(manual_number) into @manual_number from sc_debit_header where manual_number is not null;
    if @manual_number is null then
      set @manual_number = 1
    end if;
    set @manual_number = @manual_number+1;
    --Debit Header
    insert into sc_debit_header
      ( debit_header,
      manual_number,
      trans_id,
      debit_date,
      trans_time,
      confirm_date,
      store_id,
      cus_code,
      customer_name,
      status,
      trans_flag,
      debit_type,
      sell_way,
      service_center,
      location_id,
      user_name,
      salesman_id,
      quotation_no,
      quotation_location_id,
      notes ) values
      ( @debit_header,
      @manual_number,
      1, --trans id debit order
      GetDate(),
      GetDate(),
      GetDate(),
      @store_id, --Store Id
      @invoice_customerId,
      @invoice_customer_name,
      2, --status
      'M', --trans_flag
      2, --debit_type
      1, --sell_way
      @service_center,
      @location_id,
      @invoice_user_id,
      @invoice_salesman_id,
      @invoice_quotation_id,
      @invoice_quotation_location_id,
      'Sale Invoice' ) ;
    --Debit Details
    insert into sc_debit_detail
      ( debit_detail,
      debit_header,
      item_id,
      qty,
      price,
      official_price,
      fob_price,
      item_cost,
      official_cost,
      exp,
      invoicetype,
      status,
      service_center,
      location_id,
      notes ) 
      select invoicedetailid,
        @debit_header,
        itemid,
        qty,
        price,
        price, --official_price,  
        price, --fob_price,
        (select sc_balance.price
          from sc_balance where(sc_balance.item_id = ws_invoicedetail.itemid and sc_balance.store_id = @store_id
          and sc_balance.service_center = @service_center and sc_balance.location_id = @location_id)), --item_cost,       
        (select sc_balance.official_price
          from sc_balance where(sc_balance.item_id = ws_invoicedetail.itemid and sc_balance.store_id = @store_id
          and sc_balance.service_center = @service_center and sc_balance.location_id = @location_id)), --official_cost,   
        '1900-01-01',
        invoicetype,
        2,
        @service_center,
        @location_id,
        ''
        from ws_invoicedetail
        where(ws_invoicedetail.invoiceid = @InvoiceID and ws_invoicedetail.invoicetype = @InvoiceType)
        and(ws_invoicedetail.service_center = @service_center and ws_invoicedetail.location_id = @location_id);
    --Sc_balance
    open cursor_items;
    MyLoop: loop
      fetch next cursor_items into @itemid,@qty,@price;
      if sqlstate = err_notfound then
        leave MyLoop
      end if;
      --Adjust Balance 
      update sc_balance set balance = balance-@qty
        where(item_id = @itemid and exp = '1900-01-01' and store_id = @store_id and service_center = @service_center and location_id = @location_id)
    end loop MyLoop;
    close cursor_items;
    --Update Invoice 
    update ws_invoiceheader set debit_header = @debit_header
      where(invoiceid = @InvoiceID and invoicetype = @InvoiceType and service_center = @service_center and location_id = @location_id)
  end if; --nature
  --Return Order-----------------------------------------------------------------------------------------------------------------------------------------
  -------------------------------------------------------------------------------------------------------------------------------------------------------
  if @invoice_nature = 'R' then
    select Max(credit_header) into @credit_header from sc_ret_header where(service_center = @service_center and location_id = @location_id);
    if @credit_header is null then
      set @credit_header = 1
    end if;
    set @credit_header = @credit_header+1;
    select Max(manual_number) into @manual_number from sc_ret_header where(service_center = @service_center and location_id = @location_id and manual_number is not null);
    if @manual_number is null then
      set @manual_number = 1
    end if;
    set @manual_number = @manual_number+1;
    --Return Header
    insert into sc_ret_header
      ( credit_header,
      manual_number,
      credit_date,
      trans_time,
      store_id,
      inv_status,
      service_center,
      location_id,
      user_name,
      salesman_id,
      debit_header,
      debit_location,
      notes ) values
      ( @credit_header,
      @manual_number,
      GetDate(),
      GetDate(),
      @store_id, --Store Id
      @invoice_status,
      @service_center,
      @location_id,
      @invoice_user_id,
      @invoice_salesman_id,
      @invoice_debit_header,
      @location_id,
      'Sale Invoice Return' ) ;
    --Return Details
    insert into sc_ret_detail
      ( credit_detail,
      credit_header,
      item_id,
      qty,
      price,
      official_price,
      cost_price,
      item_cost,
      official_cost,
      exp,
      invoicetype,
      service_center,
      location_id,
      notes ) 
      select invoicedetailid,
        @credit_header,
        itemid,
        qty,
        price,
        price, --official_price,  
        (select item_cost from sc_debit_detail where sc_debit_detail.debit_header = @invoice_debit_header
          and sc_debit_detail.service_center = @service_center and sc_debit_detail.location_id = @location_id and sc_debit_detail.item_id = ws_invoicedetail.itemid), --cost_price,
        (select sc_balance.price
          from sc_balance where(sc_balance.item_id = ws_invoicedetail.itemid and sc_balance.store_id = @store_id
          and sc_balance.service_center = @service_center and sc_balance.location_id = @location_id)), --item_cost,  		
        (select sc_balance.official_price
          from sc_balance where(sc_balance.item_id = ws_invoicedetail.itemid and sc_balance.store_id = @store_id
          and sc_balance.service_center = @service_center and sc_balance.location_id = @location_id)), --official_cost,   
        '1900-01-01',
        invoicetype,
        @service_center,
        @location_id,
        ''
        from ws_invoicedetail
        where(ws_invoicedetail.invoiceid = @InvoiceID and ws_invoicedetail.invoicetype = @InvoiceType)
        and(ws_invoicedetail.service_center = @service_center and ws_invoicedetail.location_id = @location_id);
    --Sc_balance
    open cursor_items;
    MyLoop: loop
      fetch next cursor_items into @itemid,@qty,@price;
      if sqlstate = err_notfound then
        leave MyLoop
      end if;
      --Adjust Balance and Cost	 
      select balance,price into @balance,@cost from sc_balance
        where(item_id = @itemid and exp = '1900-01-01' and store_id = @store_id and service_center = @service_center and location_id = @location_id);
      set @newBalance = @balance+@qty;
      if @newBalance <= 0 then
        set @newCost = @cost
      else
        set @newCost = (@balance*@cost+@qty*@price)/(@balance+@qty)
      end if;
      update sc_balance set balance = @newBalance,price = @newCost
        where(item_id = @itemid and exp = '1900-01-01' and store_id = @store_id and service_center = @service_center and location_id = @location_id);
      --Update return with new calc cost 
      update sc_ret_detail set item_cost = @newCost
        where(credit_header = @credit_header and item_id = @itemid and service_center = @service_center and location_id = @location_id)
    end loop MyLoop;
    close cursor_items;
    --Update Invoice with created return 
    update ws_invoiceheader set credit_header = @credit_header
      where(invoiceid = @InvoiceID and invoicetype = @InvoiceType and service_center = @service_center and location_id = @location_id)
  --nature
  end if
end
