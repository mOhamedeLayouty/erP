-- VIEW: Ledger.vi_bal
-- generated_at: 2025-12-29T14:36:30.563Z
-- object_id: 14120
-- table_id: 1416
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view ledger.vi_bal( acc_no,acc_parent,bran2acc,jrnl_date,curr_id,cr,db,credit,debit,company_code,doc_date,cost_no_1,cost_no_2,cost_no_3,cost_no_4 ) 
  as select jrnl_son.acc_no,
    account.acc_parent,
    account.bran2acc,
    jrnl_son.jrnl_date,
    jrnl_son.curr_id,
    jrnl_son.cr,jrnl_son.db,
    jrnl_son.credit,
    jrnl_son.debit,
    jrnl_son.company_code,
    jrnl_son.doc_date,
    jrnl_son.cost_no,
    jrnl_son.cost_no_2,
    jrnl_son.cost_no_3,
    jrnl_son.cost_no_4
    from ledger.account,ledger.jrnl_son
    where(jrnl_son.acc_no = account.acc_no) and(
    jrnl_son.company_code = account.company_code) and((
    jrnl_son.flag = '00'))
