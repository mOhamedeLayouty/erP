-- PF: UNKNOWN_SCHEMA.sp_addmessage
-- proc_id: 6
-- generated_at: 2025-12-29T13:53:28.692Z

create procedure dbo.sp_addmessage( 
  in @message_num integer,
  in @message_text varchar(255),
  in @language integer default null ) 
begin
  call dbo.sp_checkperms('RESOURCE');
  execute immediate with quotes on
    'create message ' || @message_num
     || ' as '''
     || replace(@message_text,'''','''''')
     || ''' user "' || current user || '"'
end
