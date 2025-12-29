-- PF: UNKNOWN_SCHEMA.car_cash_balance
-- proc_id: 376
-- generated_at: 2025-12-29T13:53:28.801Z

create function DBA.car_cash_balance( in ad_balancedate date,in as_type char(1),in as_payway char(1),in an_cash integer,in an_store integer,in an_brand integer,in as_currency varchar(5) default 'LE' ) 
returns decimal
begin
  declare ln_income decimal;
  declare ln_expens decimal;
  declare ln_income_cc decimal;
  declare ln_expens_cc decimal;
  if as_payway = '#' then
    select sum(car_cash_move.receipt_amount),sum(car_cash_move.pay_cyy) into ln_income,ln_income_cc
      from car_cash_move
      where(car_cash_move.income = 1 or car_cash_move.income = 3 or car_cash_move.income = 5)
      and car_cash_move.receipt_date < ad_balancedate and(car_cash_move.cash_id = an_cash or an_cash = 0)
      and(car_cash_move.log_store = an_store and car_cash_move.brand = an_brand and car_cash_move.ccy_id = as_currency);
    select sum(car_cash_move.receipt_amount),sum(car_cash_move.pay_cyy) into ln_expens,ln_expens_cc
      from car_cash_move
      where(car_cash_move.income = 2 or car_cash_move.income = 4 or car_cash_move.income = 6)
      and car_cash_move.receipt_date < ad_balancedate and(car_cash_move.cash_id = an_cash or an_cash = 0)
      and(car_cash_move.log_store = an_store and car_cash_move.brand = an_brand and car_cash_move.ccy_id = as_currency)
  else
    select sum(car_cash_move.receipt_amount),sum(car_cash_move.pay_cyy) into ln_income,ln_income_cc
      from car_cash_move
      where(car_cash_move.income = 1 or car_cash_move.income = 3 or car_cash_move.income = 5)
      and car_cash_move.receipt_date < ad_balancedate and car_cash_move.receipt_type = as_payway and(car_cash_move.cash_id = an_cash or an_cash = 0)
      and(car_cash_move.log_store = an_store and car_cash_move.brand = an_brand and car_cash_move.ccy_id = as_currency);
    select sum(car_cash_move.receipt_amount),sum(car_cash_move.pay_cyy) into ln_expens,ln_expens_cc
      from car_cash_move
      where(car_cash_move.income = 2 or car_cash_move.income = 4 or car_cash_move.income = 6) and(car_cash_move.cash_id = an_cash or an_cash = 0)
      and car_cash_move.receipt_date < ad_balancedate and car_cash_move.receipt_type = as_payway
      and(car_cash_move.log_store = an_store and car_cash_move.brand = an_brand and car_cash_move.ccy_id = as_currency)
  end if;
  if as_type = 'A' then
    return(isnull(ln_income,0)-isnull(ln_expens,0))
  elseif as_type = 'C' then
    return(isnull(ln_income_cc,0)-isnull(ln_expens_cc,0))
  end if
end
