-- PF: UNKNOWN_SCHEMA.f_get_car_cust_balance
-- proc_id: 396
-- generated_at: 2025-12-29T13:53:28.806Z

create function DBA.f_get_car_cust_balance( in as_cust varchar(50),in an_brand integer default 1,in as_type char(1) default 'B',in ad_date date default getdate() ) 
returns numeric(20,7)
//V1.1 add date in criteria and handling D "RF"
--V1.2 make date <= instead <
--V1.3 Insurance 'INS'
begin
  declare ldc_bal decimal(20,7);
  declare ldc_bal_db decimal(20,7);
  declare ldc_bal_cr decimal(20,7);
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
  if as_type = 'D' or as_type = 'B' then
    select isnull(sum(isnull(a.doc_tot,0)),0)
      into ldc_bal_db from DBA.car_account_transaction as a
      where(a.doc_date <= ad_date) and(a.brand = an_brand or an_brand = 0)
      and a.cust_code = as_cust and a.type in( 'INV','DB','DD','DS','DC','RF','AW','INS' ) 
  end if;
  if as_type = 'C' or as_type = 'B' then
    select isnull(sum(isnull(a.doc_tot,0)),0)
      into ldc_bal_cr from DBA.car_account_transaction as a
      where(a.doc_date <= ad_date) and(a.brand = an_brand or an_brand = 0)
      and a.cust_code = as_cust and a.type in( 'CS','CC','RC','RINV' ) 
  end if;
  set ldc_bal = (ldc_bal_cr-ldc_bal_db);
  return ldc_bal
end
