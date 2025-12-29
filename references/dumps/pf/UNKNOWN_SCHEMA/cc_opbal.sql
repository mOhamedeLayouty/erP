-- PF: UNKNOWN_SCHEMA.cc_opbal
-- proc_id: 400
-- generated_at: 2025-12-29T13:53:28.807Z

create function ledger.cc_opbal( in ad_date varchar(20),in as_cc char(10),in as_cc_2 char(10),in as_cc_3 char(10),in as_cc_4 char(10),in as_acc char(20),in an_comp numeric,in as_type char(1),in as_return char(1) default 'A' ) 
returns decimal
//V.1.1 as return to return Open balance and priviouse balance
begin
  declare ldc_bal decimal;
  declare ldc_openbal decimal;
  if as_type = 'D' then
    select sum(jrnl_son.debit)
      into ldc_bal from jrnl_son
      where(jrnl_son.acc_no = as_acc)
      and(jrnl_son.cost_no = as_cc or as_cc = '' or as_cc is null)
      and(jrnl_son.cost_no_2 = as_cc_2 or as_cc_2 = '' or as_cc_2 is null)
      and(jrnl_son.cost_no_3 = as_cc_3 or as_cc_3 = '' or as_cc_3 is null)
      and(jrnl_son.cost_no_4 = as_cc_4 or as_cc_4 = '' or as_cc_4 is null)
      and(jrnl_son.company_code = an_comp) and(jrnl_son.flag <> 'XX')
      and(jrnl_son.jrnl_date < ad_date);
    select sum(acc_open_bal.o_bal_db)
      into ldc_openbal from acc_open_bal
      where(acc_open_bal.acc_no = as_acc)
      and(acc_open_bal.company_code = an_comp)
      and(acc_open_bal.cost_no = as_cc or as_cc = '' or as_cc is null)
      and(acc_open_bal.cost_no_2 = as_cc_2 or as_cc_2 = '' or as_cc_2 is null)
      and(acc_open_bal.cost_no_3 = as_cc_3 or as_cc_3 = '' or as_cc_3 is null)
      and(acc_open_bal.cost_no_4 = as_cc_4 or as_cc_4 = '' or as_cc_4 is null)
  else
    select sum(jrnl_son.credit)
      into ldc_bal from jrnl_son
      where(jrnl_son.acc_no = as_acc)
      and(jrnl_son.cost_no = as_cc or as_cc = '' or as_cc is null)
      and(jrnl_son.cost_no_2 = as_cc_2 or as_cc_2 = '' or as_cc_2 is null)
      and(jrnl_son.cost_no_3 = as_cc_3 or as_cc_3 = '' or as_cc_3 is null)
      and(jrnl_son.cost_no_4 = as_cc_4 or as_cc_4 = '' or as_cc_4 is null)
      and(jrnl_son.company_code = an_comp) and(jrnl_son.flag <> 'XX')
      and(jrnl_son.jrnl_date < ad_date);
    select sum(acc_open_bal.o_bal_cr)
      into ldc_openbal from acc_open_bal
      where(acc_open_bal.acc_no = as_acc)
      and(acc_open_bal.company_code = an_comp)
      and(acc_open_bal.cost_no = as_cc or as_cc = '' or as_cc is null)
      and(acc_open_bal.cost_no_2 = as_cc_2 or as_cc_2 = '' or as_cc_2 is null)
      and(acc_open_bal.cost_no_3 = as_cc_3 or as_cc_3 = '' or as_cc_3 is null)
      and(acc_open_bal.cost_no_4 = as_cc_4 or as_cc_4 = '' or as_cc_4 is null)
  end if;
  set ldc_bal = isnull(ldc_bal,0);
  set ldc_openbal = isnull(ldc_openbal,0);
  if as_return = 'O' then
    return ldc_openbal
  elseif as_return = 'P' then
    return ldc_bal
  else
    return(ldc_bal+ldc_openbal)
  end if
end
