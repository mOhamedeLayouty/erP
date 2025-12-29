-- VIEW: Ledger.v_acc_bal_period
-- generated_at: 2025-12-29T14:36:30.562Z
-- object_id: 14168
-- table_id: 1420
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view Ledger.v_acc_bal_period /* view_column_name, ... */
  as select distinct Ledger.jrnl_son.acc_no as acc_no,
    Ledger.jrnl_son.company_code as company,
    Month(Ledger.jrnl_son.jrnl_date) as acc_month,
    datepart(year,Ledger.jrnl_son.jrnl_date) as acc_year,
    Ledger.jrnl_son.flag as flag,
    SUM(Ledger.jrnl_son.debit) as debit,
    SUM(Ledger.jrnl_son.credit) as credit,
    Ledger.jrnl_son.cost_no as cost_1,
    Ledger.jrnl_son.cost_no_2 as cost_2,
    Ledger.jrnl_son.cost_no_3 as cost_3,
    Ledger.jrnl_son.cost_no_4 as cost_4
    from Ledger.jrnl_son
    group by Ledger.jrnl_son.company_code,
    Ledger.jrnl_son.acc_no,
    Month(Ledger.jrnl_son.jrnl_date),
    datepart(year,Ledger.jrnl_son.jrnl_date),
    Ledger.jrnl_son.cost_no,
    Ledger.jrnl_son.cost_no_2,
    Ledger.jrnl_son.cost_no_3,
    Ledger.jrnl_son.cost_no_4,
    Ledger.jrnl_son.flag
