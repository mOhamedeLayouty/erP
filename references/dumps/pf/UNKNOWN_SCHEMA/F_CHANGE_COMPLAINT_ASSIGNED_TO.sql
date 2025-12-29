-- PF: UNKNOWN_SCHEMA.F_CHANGE_COMPLAINT_ASSIGNED_TO
-- proc_id: 445
-- generated_at: 2025-12-29T13:53:28.820Z

create function CRM.F_CHANGE_COMPLAINT_ASSIGNED_TO( in as_call_no varchar(20),in as_client_code varchar(10) ) 
returns varchar(15)
begin
  /*
declare as_call_no varchar(20);
declare as_client_code varchar(10);
*/
  declare as_client_contact varchar(10);
  declare as_assigned_to varchar(10);
  declare as_job varchar(100);
  declare an_job_order integer;
  declare as_job_temp varchar(100);
  declare an_job_order_temp integer;
  declare adt_due_date DATETIME;
  declare AS_CLOSED varchar(1);
  declare adt_current_time datetime;
  declare as_continue varchar(1);
  declare ai_minuts_time integer;
  declare as_status varchar(3);
  set as_continue = 'Y';
  /*
set as_call_no = '12' ;
set as_client_code = '1' ;
*/
  --------------Get Current Time--------
  select getdate() into adt_current_time;
  ---------------------------------------
  -------------------Check if Call is Open------------------
  select case when closed_Call = 0 then 'N' else 'Y' end
    into AS_CLOSED from CALLS
    where CALL_NO = as_call_no and CLIENT_CODE = as_client_code;
  -----------------------------------------------------------
  if AS_CLOSED <> 'Y' then
    ----------------------------
    select max(isnull(time_due,time_logged))
      into adt_due_date from calls where call_no = as_call_no and client_code = as_client_code;
    ---------------------------- 
    if adt_due_date > adt_current_time then
      set as_continue = 'N';
      return 'Due>Current'
    end if;
    if as_continue = 'Y' then
      select assigned_to
        into as_assigned_to from calls where call_no = as_call_no and client_code = as_client_code and isnull(time_DUE,time_logged) = adt_due_date;
      ----------------------------  
      select top 1 cc.job,cce.order_no into as_job,an_job_order
        from client_contact as CC,client_complain_escalation as cce
        where CC.contact_CODE = as_assigned_to and cc.job = cce.position_code;
      ----------------------------        
      select top 1 cc.contact_code
        into as_client_contact from client_contact as cc
        where cc.client_code = as_client_code
        and not cc.contact_code = any(select distinct ch.assigned_to from calls_history as ch,calls as c
          where(ch.call_no = as_call_no) and(ch.client_code = as_client_code)
          and(c.closed_call = 0) and(ch.call_no = c.call_no and ch.client_code = c.client_code)
          and c.call_org = 'dw_complaint')
        and CC.JOB = as_job and status = 1;
      ----------------------------  
      --IF not enough employee in the job.. change to the next job----- 
      if as_client_contact is null then
        set an_job_order_temp = an_job_order;
        set as_job_temp = as_job;
        set as_job = null;
        set an_job_order = null;
        select top 1 isnull(cce.position_code,null),isnull(cce.order_no,null)
          into as_job,an_job_order
          from client_complain_escalation as cce
          where cce.order_no = an_job_order+1;
        if an_job_order is null then
          return 'CEO'
        end if;
        ----------------------------        
        select top 1 cc.contact_code
          into as_client_contact from client_contact as cc
          where cc.client_code = as_client_code and CC.JOB = as_job and status = 1
      ---------------------------- 
      end if;
      ---------------------------------------------------------------     
      ---------------Finished Step-----------------------------------------------------------------------------
      if as_client_contact is not null then
        select new_field1
          into as_status from calls
          where call_no = as_call_no and client_code = as_client_code and closed_call = 0 and call_org = 'dw_complaint';
        select isnull(action_required_within,1) into ai_minuts_time from client_complain_escalation where position_code = as_job and status = as_status;
        update calls set date_due = dateadd(minute,ai_minuts_time,adt_due_date),
          time_due = dateadd(minute,ai_minuts_time,adt_due_date),
          assigned_to = as_client_contact
          where call_no = as_call_no and client_code = as_client_code and closed_call = 0 and call_org = 'dw_complaint';
        insert into calls_history
          select client_code,call_no,assigned_to,call_org,isnull(date_due,time_logged),isnull(time_due,time_logged),new_field1 //1= urgent /// 2= medium /// 3= normal
            from calls
            where call_no = as_call_no and client_code = as_client_code and closed_call = 0 and call_org = 'dw_complaint';
        commit work;
        return as_client_contact
      else
        return 'NoClientContact'
      ----------------------------------------------------------------------------------------------------------
      /*as_continue ='Y'*/
      end if
    end if
  else return 'Closed'
  end if
end
