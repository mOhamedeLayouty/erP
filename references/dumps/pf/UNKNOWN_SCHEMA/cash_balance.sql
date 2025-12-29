-- PF: UNKNOWN_SCHEMA.cash_balance
-- proc_id: 367
-- generated_at: 2025-12-29T13:53:28.798Z

create function DBA.cash_balance( in ad_balancedate date,in as_type char(1),in as_payway char(1),in an_cash integer,in an_center integer,in an_location integer ) 
returns decimal
begin
  declare ln_income decimal;
  declare ln_expens decimal;
  declare ln_income_cc decimal;
  declare ln_expens_cc decimal;
  if as_payway = '#' then
    select sum(cash_move.paymentamount),sum(cash_move.pay_cyy) into ln_income,ln_income_cc
      from cash_move
      where(cash_move.income = 1 or cash_move.income = 3 or cash_move.income = 5)
      and cash_move.paymentdate < ad_balancedate and(cash_move.cash_id = an_cash or an_cash = 0)
      and(cash_move.service_center = an_center and cash_move.location_id = an_location);
    select sum(cash_move.paymentamount),sum(cash_move.pay_cyy) into ln_expens,ln_expens_cc
      from cash_move
      where(cash_move.income = 2 or cash_move.income = 4)
      and cash_move.paymentdate < ad_balancedate and(cash_move.cash_id = an_cash or an_cash = 0)
      and(cash_move.service_center = an_center and cash_move.location_id = an_location)
  else
    select sum(cash_move.paymentamount),sum(cash_move.pay_cyy) into ln_income,ln_income_cc
      from cash_move
      where(cash_move.income = 1 or cash_move.income = 3 or cash_move.income = 5)
      and cash_move.paymentdate < ad_balancedate and cash_move.paymenttype = as_payway and(cash_move.cash_id = an_cash or an_cash = 0)
      and(cash_move.service_center = an_center and cash_move.location_id = an_location);
    select sum(cash_move.paymentamount),sum(cash_move.pay_cyy) into ln_expens,ln_expens_cc
      from cash_move
      where(cash_move.income = 2 or cash_move.income = 4) and(cash_move.cash_id = an_cash or an_cash = 0)
      and cash_move.paymentdate < ad_balancedate and cash_move.paymenttype = as_payway
      and(cash_move.service_center = an_center and cash_move.location_id = an_location)
  end if;
  if as_type = 'A' then
    return(isnull(ln_income,0)-isnull(ln_expens,0))
  elseif as_type = 'C' then
    return(isnull(ln_income_cc,0)-isnull(ln_expens_cc,0))
  end if
end
