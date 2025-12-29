-- PF: UNKNOWN_SCHEMA.get_budget_station_month
-- proc_id: 405
-- generated_at: 2025-12-29T13:53:28.809Z

create function ledger.get_budget_station_month( in arg_year integer,in arg_month integer,in arg_station char(30) ) 
returns numeric(15,2)
begin
  declare month_1 numeric(12,2);
  declare month_2 numeric(12,2);
  declare month_3 numeric(12,2);
  declare month_4 numeric(12,2);
  declare month_5 numeric(12,2);
  declare month_6 numeric(12,2);
  declare month_7 numeric(12,2);
  declare month_8 numeric(12,2);
  declare month_9 numeric(12,2);
  declare month_10 numeric(12,2);
  declare month_11 numeric(12,2);
  declare month_12 numeric(12,2);
  declare total_year numeric(12,2);
  select sum(distinct budg_value_1),
    sum(distinct budg_value_2),
    sum(distinct budg_value_3),
    sum(distinct budg_value_4),
    sum(distinct budg_value_5),
    sum(distinct budg_value_6),
    sum(distinct budg_value_7),
    sum(distinct budg_value_8),
    sum(distinct budg_value_9),
    sum(distinct budg_value_10),
    sum(distinct budg_value_11),
    sum(distinct budg_value_12) into month_1,
    month_2,month_3,month_4,month_5,month_6,month_7,month_8,month_9,month_10,month_11,
    month_12 from budget,account
    where(account.acc_no = budget.acc_no)
    and(account.acc_type = '4') and(budget.budg_year = arg_year)
    and(budget.cost_no = arg_station);
  if arg_month = 1 then
    set total_year = month_1
  elseif arg_month = 2 then
    set total_year = month_2
  elseif arg_month = 3 then
    set total_year = month_3
  elseif arg_month = 4 then
    set total_year = month_4
  elseif arg_month = 5 then
    set total_year = month_5
  elseif arg_month = 6 then
    set total_year = month_6
  elseif arg_month = 7 then
    set total_year = month_7
  elseif arg_month = 8 then
    set total_year = month_8
  elseif arg_month = 9 then
    set total_year = month_9
  elseif arg_month = 10 then
    set total_year = month_10
  elseif arg_month = 11 then
    set total_year = month_11
  elseif arg_month = 12 then
    set total_year = month_12
  end if;
  return(total_year)
end
