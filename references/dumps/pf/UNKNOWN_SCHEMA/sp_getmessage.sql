-- PF: UNKNOWN_SCHEMA.sp_getmessage
-- proc_id: 16
-- generated_at: 2025-12-29T13:53:28.696Z

create procedure dbo.sp_getmessage( 
  in @message_num integer,
  out @msg_var varchar(255),
  in @language char(30) default null ) 
on exception resume
begin
  set @msg_var = (select description from SYS.SYSUSERMESSAGE
      where error = @message_num)
end
