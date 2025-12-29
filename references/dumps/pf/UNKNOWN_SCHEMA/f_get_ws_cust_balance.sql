-- PF: UNKNOWN_SCHEMA.f_get_ws_cust_balance
-- proc_id: 394
-- generated_at: 2025-12-29T13:53:28.806Z

create function DBA.f_get_ws_cust_balance( in as_cust varchar(50),in an_center integer default 1,in as_type char(1) default 'B',in ad_fdate date,in @inv_cat integer default 0 ) 
returns numeric(20,7)
--V1.2 add open balance
--V1.3 add inv_type
--V1.4 add chargable invoice
--V1.5 add 'WP' in case ( if as_type = 'C' or as_type = 'B' then)
begin
  declare ldc_openbal decimal(20,7);
  declare ldc_bal decimal(20,7);
  declare ldc_bal_db decimal(20,7);
  declare ldc_bal_cr decimal(20,7);
  set ldc_openbal = 0;
  set ldc_bal = 0;
  set ldc_bal_db = 0;
  set ldc_bal_cr = 0;
  /*
declare  as_cust varchar(50);
declare an_brand integer ;
declare an_location integer ;
declare as_type char(1);

set as_cust = '0101000072' ;
set an_brand = 1;
set an_location = 1 ;
set as_type = 'B' ;
*/
  select isnull(o_bal,0) into ldc_openbal from Customer where customer_id = as_cust;
  if as_type = 'D' or as_type = 'B' then
    select sum(isnull(a.amount,0))
      into ldc_bal_db from DBA.erp_account_transaction as a
      where(a.rec_date <= ad_fdate) and(a.service_center = an_center or an_center = 0)
      and a.cust_code = as_cust and a.rec_type in( 'INV','VOC','AW','WP' ) and(a.inv_cat = @inv_cat or @inv_cat = 0);
    if ldc_openbal < 0 then
      set ldc_bal_db = abs(isnull(ldc_bal_db,0))+abs(isnull(ldc_openbal,0))
    end if end if;
  if as_type = 'C' or as_type = 'B' then
    select sum(isnull(a.amount,0))
      into ldc_bal_cr from DBA.erp_account_transaction as a
      where(a.rec_date <= ad_fdate) and(a.service_center = an_center or an_center = 0)
      and a.cust_code = as_cust and a.rec_type in( 'REC','AP','AD','RIN','OB','mAD' ) and(a.inv_cat = @inv_cat or @inv_cat = 0);
    if ldc_openbal > 0 then
      set ldc_bal_cr = isnull(ldc_bal_cr,0)+isnull(ldc_openbal,0)
    end if end if;
  set ldc_bal = (isnull(ldc_bal_cr,0)-isnull(ldc_bal_db,0));
  return ldc_bal
end
