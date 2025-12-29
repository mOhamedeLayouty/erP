-- PF: UNKNOWN_SCHEMA.sa_setsubscription
-- proc_id: 96
-- generated_at: 2025-12-29T13:53:28.719Z

create procedure SYS.sa_setsubscription( 
  p_publication_id unsigned integer,
  p_user_id unsigned integer,
  p_subscribe_by char(128),
  p_created numeric(20),
  p_started numeric(20) ) 
begin
  update SYS.SYSSUBSCRIPTION
    set created = p_created,
    started = p_started
    where publication_id = p_publication_id
    and user_id = p_user_id
    and subscribe_by = p_subscribe_by;
  commit work
end
