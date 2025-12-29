-- VIEW: DBA.vi_bal
-- generated_at: 2025-12-29T14:36:30.562Z
-- object_id: 14054
-- table_id: 1408
-- source_via: SYS.SYSVIEW(view_object_id=object_id)

create view DBA.vi_bal( acc_no,acc_parent,bran2acc,jrnl_date,curr_id,cr,db,credit,debit,company_code ) as select jrnl_son.acc_no,account.acc_parent,account.bran2acc,jrnl_son.jrnl_date,jrnl_son.curr_id,jrnl_son.cr,jrnl_son.db,jrnl_son.credit,jrnl_son.debit,account.company_code from ledger.account,ledger.jrnl_son where(jrnl_son.acc_no = account.acc_no) and(jrnl_son.company_code = account.company_code) and((jrnl_son.flag = '00'))
