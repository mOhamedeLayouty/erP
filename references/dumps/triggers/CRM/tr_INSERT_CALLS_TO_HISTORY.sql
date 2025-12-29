-- TRIGGER: CRM.tr_INSERT_CALLS_TO_HISTORY
-- ON TABLE: CRM.calls
-- generated_at: 2025-12-29T13:52:33.696Z

create trigger tr_INSERT_CALLS_TO_HISTORY after insert order 1 on
CRM.CALLS
referencing new as INSERTED
for each row /* WHEN( search_condition ) */
begin
  declare @CALL_NO varchar(10);
  declare @CLIENT_CODE varchar(10);
  declare @as_job varchar(5);
  declare @CALL_ORG varchar(20);
  declare @ASSIGNED_TO varchar(10);
  declare @AS_status varchar(3);
  declare @minuts_time integer;
  set @CALL_NO = INSERTED.call_no;
  set @CLIENT_CODE = INSERTED.CLIENT_CODE;
  set @CALL_ORG = INSERTED.CALL_ORG;
  set @ASSIGNED_TO = INSERTED.assigned_to;
  if @CALL_ORG = 'dw_complaint' then
    if @CALL_NO is not null then
      select top 1 cc.job
        into @as_job from client_contact as CC,client_complain_escalation as cce
        where CC.contact_CODE = @ASSIGNED_TO and cc.job = cce.position_code;
      ---------------------------------------------------------
      set @AS_status = INSERTED.new_field1;
      ---------------------------------------------------------
      select isnull(action_required_within,1)
        into @minuts_time from client_complain_escalation
        where position_code = @as_job and status = @AS_status;
      ---------------------------------------------------------
      update calls set calls.date_due = dateadd(minute,@minuts_time,ISNULL(calls.date_due,calls.date_logged)),
        time_due = dateadd(minute,@minuts_time,ISNULL(calls.date_due,calls.date_logged))
        where calls.call_no = @call_no and calls.client_code = @client_code and calls.closed_call = 0 and calls.call_org = 'dw_complaint';
      ---------------------------------------------------------   
      insert into calls_history
        select INSERTED.client_code,INSERTED.call_no,INSERTED.assigned_to,INSERTED.call_org,isnull(INSERTED.date_due,INSERTED.time_logged),
          isnull(INSERTED.time_due,INSERTED.time_logged),INSERTED.new_field1 //1= urgent /// 2= medium /// 3= normal
    ---------------------------------------------------------
    end if
  end if
end
