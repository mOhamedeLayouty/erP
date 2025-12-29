-- PF: UNKNOWN_SCHEMA.sr_update_message_server
-- proc_id: 287
-- generated_at: 2025-12-29T13:53:28.776Z

create procedure dbo.sr_update_message_server( 
  in @owner varchar(128) default current user ) 
begin
  call dbo.sr_drop_message_server();
  call dbo.sr_add_message_server(@owner)
end
