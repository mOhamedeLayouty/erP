-- PF: UNKNOWN_SCHEMA.get_Accopbal
-- proc_id: 401
-- generated_at: 2025-12-29T13:53:28.808Z

create function Ledger.get_Accopbal( in an_fcost char(10),in an_tcost char(10),in an_fcost2 char(10),in an_tcost2 char(10),in an_fcost3 char(10),in an_tcost3 char(10),in an_fcost4 char(10),in an_tcost4 char(10),in as_acc char(10),in an_comp numeric,in as_type char(1) ) 
returns decimal
begin
  declare ldc_bal decimal;
  declare ldc_openbal decimal;
  if as_type = 'D' then
    select sum(acc_open_bal.o_bal_db)
      into ldc_openbal from acc_open_bal
      where(acc_open_bal.acc_no = as_acc)
      and(acc_open_bal.company_code = an_comp)
      and(acc_open_bal.cost_no between an_fcost and an_tcost or an_fcost = '' or an_fcost is null
      or an_tcost = '' or an_tcost is null)
      and(acc_open_bal.cost_no_2 between an_fcost2 and an_tcost2 or an_fcost2 = '' or an_fcost2 is null
      or an_tcost2 = '' or an_tcost2 is null)
      and(acc_open_bal.cost_no_3 between an_fcost3 and an_tcost3 or an_fcost3 = '' or an_fcost3 is null
      or an_tcost3 = '' or an_tcost3 is null)
      and(acc_open_bal.cost_no_4 between an_fcost4 and an_tcost4 or an_fcost4 = '' or an_fcost4 is null
      or an_tcost4 = '' or an_tcost4 is null)
  else
    select sum(acc_open_bal.o_bal_cr)
      into ldc_openbal from acc_open_bal
      where(acc_open_bal.acc_no = as_acc)
      and(acc_open_bal.company_code = an_comp)
      and(acc_open_bal.cost_no between an_fcost and an_tcost or an_fcost = '' or an_fcost is null
      or an_tcost = '' or an_tcost is null)
      and(acc_open_bal.cost_no_2 between an_fcost2 and an_tcost2 or an_fcost2 = '' or an_fcost2 is null
      or an_tcost2 = '' or an_tcost2 is null)
      and(acc_open_bal.cost_no_3 between an_fcost3 and an_tcost3 or an_fcost3 = '' or an_fcost3 is null
      or an_tcost3 = '' or an_tcost3 is null)
      and(acc_open_bal.cost_no_4 between an_fcost4 and an_tcost4 or an_fcost4 = '' or an_fcost4 is null
      or an_tcost4 = '' or an_tcost4 is null)
  end if;
  set ldc_openbal = isnull(ldc_openbal,0);
  return(ldc_openbal)
end
