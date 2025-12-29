-- PF: UNKNOWN_SCHEMA.sp_dropmessage
-- proc_id: 13
-- generated_at: 2025-12-29T13:53:28.695Z

create procedure dbo.sp_dropmessage( 
  in @message_number integer,
  in @language char(30) default null ) 
begin
  call dbo.sp_checkperms('RESOURCE');
  execute immediate with quotes on
    'drop message ' || @message_number
end
