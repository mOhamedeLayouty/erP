-- PF: UNKNOWN_SCHEMA.SP_SMS_Update
-- proc_id: 426
-- generated_at: 2025-12-29T13:53:28.815Z

create procedure DBA.SP_SMS_Update( 
  in @record_id varchar(13),
  in @sent_msg varchar(500),
  out @flag varchar(1) ) 
--Ver 1.0
begin
  declare flag varchar(13);
  update sms_messages
    set sent_flag = 1,
    sent_on = now(),
    sent_msg = @sent_msg
    where record_id = @record_id;
  if sqlstate = '00000' then
    set @flag = '1'
  else
    set @flag = '0'
  end if;
  select @flag
end
