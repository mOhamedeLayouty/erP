-- PF: UNKNOWN_SCHEMA.SP_report_sheet_months
-- proc_id: 440
-- generated_at: 2025-12-29T13:53:28.819Z

create procedure --/*
ledger.SP_report_sheet_months( an_company_id integer,as_design_code varchar(10),
  as_report_type varchar(5),adt_f_date date,adt_t_date date,
  as_CCflag varchar(50) default '0',as_CC2flag varchar(50) default '0',as_CC3flag varchar(50) default '0',as_CC4flag varchar(50) default '0',
  as_CC varchar(50) default '0',as_CC2 varchar(50) default '0',as_CC3 varchar(50) default '0',as_CC4 varchar(50) default '0' ) 
--*/
begin
  declare AN_LINE_NO integer;
  declare AS_ACC_NAME varchar(100);
  declare AS_ACC_FROM varchar(20);
  declare AS_ACC_TO varchar(20);
  declare AS_LINE_TYPE varchar(5);
  declare as_formula varchar(5000);
  /*
declare an_company_id integer;
declare as_design_code varchar(10) ;
declare as_report_type varchar(5) ; 
declare adt_f_date date  ;
declare adt_t_date date  ;
declare as_CCflag varchar(50); 
declare as_CC2flag varchar(50);  
declare as_CC3flag varchar(50);
declare as_CC4flag varchar(50);
declare as_CC varchar(50);
declare  as_CC2 varchar(50);
declare  as_CC3 varchar(50);
declare  as_CC4 varchar(50);





set an_company_id = 2 ;
set as_design_code = '1' ;
set as_report_type = 'TR' ;
set adt_f_date = cast( '2015-01-01' as date) ;
set adt_t_date = cast('2015-12-31' as date) ;
set as_ccflag = '0' ;
set as_cc2flag = '0' ;
set as_cc3flag = '0';  
set as_cc4flag = '0' ;
set as_cc = '0' ;
set as_cc2 = '0' ;
set as_cc3 = '0'  ;
set as_cc4= '0' ;

*/
  select cr_report.line_no,cr_report.line_type,cr_report.acc_name,cr_report.acc_from,cr_report.acc_to,cr_report.formula
    into #c_report
    from ledger.cr_report
    where cr_report.company_code = an_company_id and cr_report.design_code = as_design_code and cr_report.report_type = as_report_type;
  select * into #c_report2 from #c_report;
  /*
SELECT * FROM #C_REPORT2 
DROP TABLE #C_REPORT2 
END
*/
  -----------------------------------------------------------------------------------------------------------------------------------------
  while(select count(#c_report.line_no) from #c_report) > 0 loop
    select top 1 line_no,ACC_NAME,ACC_FROM,ACC_TO,LINE_TYPE,formula into AN_LINE_NO,AS_ACC_NAME,AS_ACC_FROM,AS_ACC_TO,AS_LINE_TYPE,as_formula from #c_report;
    if AN_LINE_NO = 1 then
      select as_acc_name,as_line_type,an_line_no,jrnl_son.acc_no,as_formula,
        case when as_line_type = 'ACC' then isnull(Sum(isnull(jrnl_son.credit,0)-isnull(jrnl_son.debit,0)),0)
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,0,an_line_no)
        end as total,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 1) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,1,an_line_no)
        end as January,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 2) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,2,an_line_no)
        end as Febuary,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 3) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,3,an_line_no)
        end as March,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 4) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,4,an_line_no)
        end as April,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 5) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,5,an_line_no)
        end as May,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 6) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,6,an_line_no)
        end as June,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 7) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,7,an_line_no)
        end as July,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 8) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,8,an_line_no)
        end as August,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 9) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,9,an_line_no)
        end as September,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 10) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,10,an_line_no)
        end as October,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 11) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,11,an_line_no)
        end as November,
        case when as_line_type = 'ACC' then
          (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 12) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
        else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,12,an_line_no)
        end as December
        into #REPORT_SHEET_MONTHS
        from ledger.jrnl_son
        where(jrnl_son.flag = '00')
        and(jrnl_son.company_code = an_company_id)
        and((jrnl_son.acc_no between as_acc_from and as_acc_to) or(as_acc_from = '' and as_acc_to = ''))
        and(jrnl_son.jrnl_date between adt_f_date and adt_t_date)
        and(jrnl_son.cost_no in( as_CC ) or '0' = as_CCflag)
        and(jrnl_son.cost_no_2 in( as_CC2 ) or '0' = as_CC2flag)
        and(jrnl_son.cost_no_3 in( as_CC3 ) or '0' = as_CC3flag)
        and(jrnl_son.cost_no_4 in( as_CC4 ) or '0' = as_CC4flag)
        group by an_line_no,as_acc_name,jrnl_son.company_code,as_line_type,jrnl_son.acc_no,jrnl_son.jrnl_date
        order by an_line_no asc
    else
      insert into #REPORT_SHEET_MONTHS
        select as_acc_name,as_line_type,an_line_no,jrnl_son.acc_no,as_formula,
          case when as_line_type = 'ACC' then isnull(Sum(isnull(jrnl_son.credit,0)-isnull(jrnl_son.debit,0)),0)
          else 200 --ledger.f_get_compute_value(an_company_id , as_design_code , as_report_type , adt_f_date , adt_t_date , as_CCflag , as_CC2flag , as_CC3flag , as_CC4flag ,as_CC , as_CC2 , as_CC3 , as_CC4 , 0 , an_line_no) 
          end as total,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 1) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,1,an_line_no)
          end as January,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 2) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,2,an_line_no)
          end as Febuary,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 3) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,3,an_line_no)
          end as March,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 4) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,4,an_line_no)
          end as April,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 5) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,5,an_line_no)
          end as May,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 6) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,6,an_line_no)
          end as June,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 7) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,7,an_line_no)
          end as July,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 8) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,8,an_line_no)
          end as August,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 9) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,9,an_line_no)
          end as September,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 10) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,10,an_line_no)
          end as October,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 11) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,11,an_line_no)
          end as November,
          case when as_line_type = 'ACC' then
            (select isnull(Sum(isnull(j1.credit,0)-isnull(j1.debit,0)),0) from ledger.jrnl_son as j1 where((jrnl_son.jrnl_date = j1.jrnl_date) and month(j1.jrnl_date) = 12) and jrnl_son.acc_no = j1.acc_no and j1.company_code = jrnl_son.company_code and j1.flag = '00')
          else ledger.f_get_compute_value(an_company_id,as_design_code,as_report_type,adt_f_date,adt_t_date,as_CCflag,as_CC2flag,as_CC3flag,as_CC4flag,as_CC,as_CC2,as_CC3,as_CC4,12,an_line_no)
          end as December
          from ledger.jrnl_son
          where(jrnl_son.flag = '00')
          and(jrnl_son.company_code = an_company_id)
          and((jrnl_son.acc_no between as_acc_from and as_acc_to) or(as_acc_from = '' and as_acc_to = ''))
          and(jrnl_son.jrnl_date between adt_f_date and adt_t_date)
          and(jrnl_son.cost_no in( as_CC ) or '0' = as_CCflag)
          and(jrnl_son.cost_no_2 in( as_CC2 ) or '0' = as_CC2flag)
          and(jrnl_son.cost_no_3 in( as_CC3 ) or '0' = as_CC3flag)
          and(jrnl_son.cost_no_4 in( as_CC4 ) or '0' = as_CC4flag)
          group by an_line_no,as_acc_name,jrnl_son.company_code,as_line_type,jrnl_son.acc_no,jrnl_son.jrnl_date
          order by an_line_no asc
    end if;
    delete from #c_report where LINE_NO = AN_LINE_NO
  end loop;
  ----------------------------------------
  select as_formula,ISNULL(as_acc_name,#C_REPORT2.ACC_NAME) as ACC_NAME,ISNULL(an_line_no,#C_REPORT2.LINE_NO) as ACC_LINE_NO,ISNULL(as_line_type,#c_report2.line_type) as ACC_LINE_TYPE,
    ISNULL(sum(total),0) as total,ISNULL(sum(january),0) as january,ISNULL(sum(Febuary),0) as Febuary,ISNULL(sum(MARCH),0) as MARCH,ISNULL(sum(APRIL),0) as APRIL,ISNULL(sum(MAY),0) as MAY,
    ISNULL(sum(June),0) as June,ISNULL(sum(JULY),0) as JULY,ISNULL(sum(August),0) as August,ISNULL(sum(September),0) as September,ISNULL(sum(OCTOBER),0) as OCTOBER,ISNULL(sum(November),0) as November,ISNULL(SUM(December),0) as December
    from #REPORT_SHEET_MONTHS right outer join #C_REPORT2 on AN_LINE_NO = #C_REPORT2.LINE_NO
    group by as_formula,ISNULL(an_line_no,#C_REPORT2.LINE_NO),ISNULL(as_acc_name,#C_REPORT2.ACC_NAME),ISNULL(as_line_type,#c_report2.line_type)
    order by ISNULL(an_line_no,#C_REPORT2.LINE_NO) asc;
  commit work;
  drop table #c_report;
  drop table #c_report2;
  drop table #REPORT_SHEET_MONTHS
end
