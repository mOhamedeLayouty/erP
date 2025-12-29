-- PF: UNKNOWN_SCHEMA.pr_ledger_like
-- proc_id: 438
-- generated_at: 2025-12-29T13:53:28.818Z

create procedure ledger.pr_ledger_like( in acc_fr char(20),in date_fr date,in date_to date,in cr_id char(3) ) 
begin
  delete from rep_led_info;
  if @@error <> 0 then
    return
  end if;
  //------------------------------------------------------------------------------------------------------//
  if cr_id = 'ALL' then
    //------------------------Opening Balance----------------------------------------------------------//
    insert into rep_led_info( acc_no,debit,credit,note ) (
      select account.acc_no,account.o_bal_db,account.o_bal_cr,'Z-OPEN-B'
        from account
        where(account.acc_level = 2)
        and(account.acc_no like acc_fr));
    //---------------------------Befor Balance----------------------------------------------------------//
    insert into rep_led_info( acc_no,debit,credit,note ) (
      select jrnl_son.acc_no,SUM(jrnl_son.debit),SUM(jrnl_son.credit),'Z-BE-FOR'
        from jrnl_son
        where(jrnl_son.jrnl_date < date_fr)
        and(jrnl_son.flag = '00')
        group by jrnl_son.acc_no
        having(jrnl_son.acc_no like acc_fr));
    //------------------------------Ledger Legs-------------------------------------------------------------//
    insert into rep_led_info( line_no,acc_no,jrnl_no,jrnl_date,debit,credit,note,curr_id ) (
      select jrnl_son.line_no,jrnl_son.acc_no,
        jrnl_son.jrnl_no,jrnl_son.jrnl_date,
        jrnl_son.debit,jrnl_son.credit,jrnl_son.note,jrnl_son.curr_id
        from jrnl_son
        where(jrnl_son.flag = '00')
        and(jrnl_son.acc_no like acc_fr)
        and(jrnl_son.jrnl_date between date_fr and date_to))
  else
    //------------------------Opening Balance----------------------------------------------------------//
    insert into rep_led_info( acc_no,debit,credit,note ) (
      select acc_open_bal.acc_no,acc_open_bal.o_bal_db_c,acc_open_bal.o_bal_cr_c,'Z-OPEN-B'
        from acc_open_bal
        where(acc_open_bal.curr_id = cr_id)
        and(acc_open_bal.acc_no like acc_fr));
    //---------------------------Befor Balance----------------------------------------------------------//
    insert into rep_led_info( acc_no,debit,credit,note ) (
      select jrnl_son.acc_no,SUM(jrnl_son.db),SUM(jrnl_son.cr),'Z-BE-FOR'
        from jrnl_son
        where(jrnl_son.jrnl_date < date_fr)
        and(jrnl_son.flag = '00')
        and(jrnl_son.curr_id = cr_id)
        group by jrnl_son.acc_no
        having(jrnl_son.acc_no like acc_fr));
    //------------------------------Ledger Legs-------------------------------------------------------------//
    insert into rep_led_info( line_no,acc_no,jrnl_no,jrnl_date,debit,credit,note,curr_id ) (
      select jrnl_son.line_no,jrnl_son.acc_no,
        jrnl_son.jrnl_no,jrnl_son.jrnl_date,
        jrnl_son.db,jrnl_son.cr,jrnl_son.note,jrnl_son.curr_id
        from jrnl_son
        where(jrnl_son.flag = '00')
        and(jrnl_son.acc_no like acc_fr)
        and(jrnl_son.jrnl_date between date_fr and date_to)
        and(jrnl_son.curr_id = cr_id))
  end if
end
