-- PF: UNKNOWN_SCHEMA.pr_ledger
-- proc_id: 437
-- generated_at: 2025-12-29T13:53:28.818Z

create procedure Ledger.pr_ledger( in acc_fr char(20),in acc_to char(20),in date_fr date,in date_to date,in cr_id char(3),in a_company_code integer,in a_user_per char(2) default 'AL' ) 
begin
  //V1 handling repeated open balance 
  //V1.1 handling privilige on user levels
  delete from rep_led_info;
  if @@error <> 0 then
    return
  end if;
  if cr_id = 'ALL' then
    insert into rep_led_info( acc_no,debit,credit,note,company_code ) (
      select account.acc_no,account.o_bal_db,account.o_bal_cr,'Z-OPEN-B',account.company_code
        from account
        where(account.acc_level = 2)
        and((a_user_per = 'AL') or(a_user_per = 'AC' and account.usr_per in( 'AC' ) ) or(a_user_per = 'AU' and account.usr_per in( 'AC','AU' ) ))
        and(account.acc_no between acc_fr and acc_to) and(account.company_code = a_company_code));
    insert into rep_led_info( acc_no,debit,credit,note,company_code ) (
      select jrnl_son.acc_no,SUM(jrnl_son.debit),SUM(jrnl_son.credit),'Z-BE-FOR',jrnl_son.company_code
        from jrnl_son,account
        where(jrnl_son.acc_no = account.acc_no)
        and(jrnl_son.company_code = account.company_code)
        and((a_user_per = 'AL') or(a_user_per = 'AC' and account.usr_per in( 'AC' ) ) or(a_user_per = 'AU' and account.usr_per in( 'AC','AU' ) ))
        and(jrnl_son.jrnl_date < date_fr)
        and(jrnl_son.flag = '00') and(jrnl_son.company_code = a_company_code)
        group by jrnl_son.acc_no,jrnl_son.company_code
        having(jrnl_son.acc_no between acc_fr and acc_to));
    insert into rep_led_info( line_no,acc_no,jrnl_no,jrnl_date,debit,credit,note,curr_id,doc_date,doc_type_no,company_code,rec_type_serial ) (
      select jrnl_son.line_no,jrnl_son.acc_no,
        jrnl_son.jrnl_no,jrnl_son.jrnl_date,
        jrnl_son.debit,jrnl_son.credit,jrnl_son.note,jrnl_son.curr_id,jrnl_son.doc_date,jrnl_son.doc_type_no,jrnl_son.company_code,jrnl_father.rec_type_serial
        from jrnl_son,jrnl_father,account
        where(jrnl_son.acc_no = account.acc_no)
        and(jrnl_son.company_code = account.company_code)
        and((a_user_per = 'AL') or(a_user_per = 'AC' and account.usr_per in( 'AC' ) ) or(a_user_per = 'AU' and account.usr_per in( 'AC','AU' ) ))
        and(jrnl_son.flag = '00')
        and(jrnl_son.acc_no between acc_fr and acc_to) and(jrnl_son.company_code = a_company_code)
        and(jrnl_son.jrnl_date between date_fr and date_to) and jrnl_father.jrnal_no = jrnl_son.jrnl_no and jrnl_father.company_code = jrnl_son.company_code)
  else
    insert into rep_led_info( acc_no,debit,credit,note,company_code ) (
      select acc_open_bal.acc_no,sum(acc_open_bal.o_bal_db_c),sum(acc_open_bal.o_bal_cr_c),'Z-OPEN-B',acc_open_bal.company_code
        from acc_open_bal,account
        where(acc_open_bal.acc_no = account.acc_no)
        and(acc_open_bal.company_code = account.company_code)
        and((a_user_per = 'AL') or(a_user_per = 'AC' and account.usr_per in( 'AC' ) ) or(a_user_per = 'AU' and account.usr_per in( 'AC','AU' ) ))
        and(acc_open_bal.curr_id = cr_id)
        and(acc_open_bal.acc_no between acc_fr and acc_to)
        and(acc_open_bal.company_code = a_company_code) group by acc_open_bal.acc_no,acc_open_bal.company_code);
    insert into rep_led_info( acc_no,debit,credit,note,company_code ) (
      select jrnl_son.acc_no,SUM(jrnl_son.db),SUM(jrnl_son.cr),'Z-BE-FOR',jrnl_son.company_code
        from jrnl_son,account
        where(jrnl_son.acc_no = account.acc_no)
        and(jrnl_son.company_code = account.company_code)
        and((a_user_per = 'AL') or(a_user_per = 'AC' and account.usr_per in( 'AC' ) ) or(a_user_per = 'AU' and account.usr_per in( 'AC','AU' ) ))
        and(jrnl_son.jrnl_date < date_fr)
        and(jrnl_son.flag = '00')
        and(jrnl_son.curr_id = cr_id) and(jrnl_son.company_code = a_company_code)
        group by jrnl_son.acc_no,jrnl_son.company_code
        having(jrnl_son.acc_no between acc_fr and acc_to));
    insert into rep_led_info( line_no,acc_no,jrnl_no,jrnl_date,debit,credit,note,curr_id,company_code,rec_type_serial ) (
      select jrnl_son.line_no,jrnl_son.acc_no,
        jrnl_son.jrnl_no,jrnl_son.jrnl_date,
        jrnl_son.db,jrnl_son.cr,jrnl_son.note,jrnl_son.curr_id,jrnl_son.company_code,rec_type_serial
        from jrnl_son,jrnl_father,account
        where(jrnl_son.acc_no = account.acc_no)
        and(jrnl_son.company_code = account.company_code)
        and((a_user_per = 'AL') or(a_user_per = 'AC' and account.usr_per in( 'AC' ) ) or(a_user_per = 'AU' and account.usr_per in( 'AC','AU' ) ))
        and(jrnl_son.flag = '00')
        and(jrnl_son.acc_no between acc_fr and acc_to) and(jrnl_son.company_code = a_company_code)
        and(jrnl_son.jrnl_date between date_fr and date_to)
        and(jrnl_son.curr_id = cr_id) and jrnl_father.jrnal_no = jrnl_son.jrnl_no and jrnl_father.company_code = jrnl_son.company_code)
  end if
end
