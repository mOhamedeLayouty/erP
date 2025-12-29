-- PF: UNKNOWN_SCHEMA.f_get_compute_value
-- proc_id: 407
-- generated_at: 2025-12-29T13:53:28.809Z

create function --/*
ledger.f_get_compute_value( in i_company_id integer,in s_design_code varchar(3),
  in s_report_type varchar(4),
  in d_from_date date,
  in d_to_date date,
  in s_ccflag varchar(10) default '0',
  in s_cc2flag varchar(10) default '0',
  in s_cc3flag varchar(10) default '0',
  in s_cc4flag varchar(10) default '0',
  in s_cc varchar(10) default '0',
  in s_cc2 varchar(10) default '0',
  in s_cc3 varchar(10) default '0',
  in s_cc4 varchar(10) default '0',
  in i_month integer,
  in i_line_no integer ) 
returns decimal
--*/
begin
  /*
declare i_company_id integer ;
declare s_design_code varchar(3) ;
declare s_report_type VARCHAR(4) ;
declare d_from_date date ;
declare d_to_date date ;
declare s_ccflag varchar(10) ; 
declare s_cc2flag varchar(10) ; 
declare s_cc3flag varchar(10) ;
declare s_cc4flag varchar(10) ;
declare s_cc varchar(10) ;
declare s_cc2 varchar(10) ;
declare s_cc3 varchar(10) ;
declare s_cc4 varchar(10) ;
declare i_month integer ;
declare i_line_no  integer ;
*/
  declare ds_compute_value decimal;
  declare ds_compute_value_all decimal;
  declare ll integer;
  declare s_LineNo_array varchar(5000);
  declare s_from_acc varchar(5000);
  declare s_to_acc varchar(5000);
  declare ls varchar(5000);
  declare LS_TEMP varchar(5000);
  declare LL_POS integer;
  declare LL_VALUE integer;
  declare ls_sign varchar(1);
  /*
set i_company_id = 2 ;
set s_design_code = '1' ;
set s_report_type = 'TR' ;
set d_from_date = cast( '2015-01-01' as date) ;
set d_to_date = cast('2015-12-31' as date) ;
set i_month = 11;
set s_ccflag = '0' ;
set s_cc2flag = '0' ;
set s_cc3flag = '0' ; 
set s_cc4flag = '0' ;
set i_line_no = 5 ;
*/
  ----------------------------------------Get Lines No--------------------------------
  set s_LineNo_array = '';
  select formula into s_LineNo_array from ledger.cr_report
    where design_code = s_design_code and company_code = i_company_id and line_no = i_line_no and report_type = s_report_type;
  if LOCATE(s_LineNo_array,'+') > 0 then
    set ls_sign = '+'
  end if;
  if LOCATE(s_LineNo_array,'-') > 0 then
    set ls_sign = '-'
  end if;
  select ledger.f_replace_string(s_LineNo_array,ls_sign,',') into ls;
  set ls = '0'+ls;
  set LS_TEMP = ls;
  ----------------------------------FILL #TEST-----------------------------------
  --delete from ledger.test ;
  set ds_compute_value_all = 0;
  set ds_compute_value = 0;
  while LEN(LS_TEMP) > 0 loop
    set LL_POS = LOCATE(LS_TEMP,',');
    delete from ledger.test;
    if LL_POS > 0 then
      set LL_VALUE = cast(substr(LS_TEMP,1,LL_POS-1) as integer);
      set LS_TEMP = substr(LS_TEMP,LL_POS+1,LEN(LS_TEMP));
      insert into ledger.test
        select cr_report.acc_from,cr_report.acc_TO,cr_report.line_no
          from ledger.cr_report
          where(cr_report.company_code = i_company_id)
          and(cr_report.design_code = s_design_code)
          and(cr_report.report_type = s_report_type)
          and(cr_report.line_no in( LL_VALUE ) and LL_VALUE > 0)
    else
      set LL_VALUE = cast(LS_TEMP as integer);
      insert into ledger.test
        select cr_report.acc_from,cr_report.acc_TO,cr_report.line_no
          from ledger.cr_report
          where(cr_report.company_code = i_company_id)
          and(cr_report.design_code = s_design_code)
          and(cr_report.report_type = s_report_type)
          and(cr_report.line_no in( LL_VALUE ) and LL_VALUE > 0);
      set LS_TEMP = ''
    end if;
    set ds_compute_value = 0;
    select distinct
      ((isnull(Sum(isnull(jrnl_son.credit,0)),0)-isnull(sum(isnull(jrnl_son.debit,0)),0)))
      /*   +
(select distinct round((isnull(sum(isnull(o_bal_cr,0)) - sum(isnull(o_bal_db,0)),0)),2) 
from ledger.acc_open_bal acc  
where (acc.acc_no between "test"."from_acc" and "test"."to_acc") and acc.company_code = i_company_id )*/
      into ds_compute_value from ledger.jrnl_son,ledger.test
      where(jrnl_son.flag = '00') and(jrnl_son.company_code = i_company_id)
      and(jrnl_son.acc_no between test.from_acc and test.to_acc)
      and(jrnl_son.jrnl_date between d_from_date and d_to_date) and(month(jrnl_son.jrnl_date) = i_month or i_month = 0)
      and(jrnl_son.cost_no in( s_CC ) or '0' = s_CCflag)
      and(jrnl_son.cost_no_2 in( s_CC2 ) or '0' = s_CC2flag)
      and(jrnl_son.cost_no_3 in( s_CC3 ) or '0' = s_CC3flag)
      and(jrnl_son.cost_no_4 in( s_CC4 ) or '0' = s_CC4flag);
    /*group by "test"."from_acc" , "test"."to_acc" */
    set ds_compute_value_all = isnull(ds_compute_value_all,0)+ds_compute_value
  end loop;
  --select ds_compute_value_all  ;
  -------------------------------------------------------------------------------
  ---------------------------------------------------------------------------------------
  return ds_compute_value_all
end
