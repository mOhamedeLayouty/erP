-- PF: UNKNOWN_SCHEMA.sa_setremoteuser
-- proc_id: 95
-- generated_at: 2025-12-29T13:53:28.719Z

create procedure SYS.sa_setremoteuser( 
  p_user_id unsigned integer,
  p_log_sent numeric(20),
  p_confirm_sent numeric(20),
  p_send_count integer,
  p_resend_count integer,
  p_log_received numeric(20),
  p_confirm_received numeric(20),
  p_receive_count integer,
  p_rereceive_count integer ) 
begin
  update SYS.SYSREMOTEUSER
    set log_sent = p_log_sent,
    confirm_sent = p_confirm_sent,
    send_count = p_send_count,
    resend_count = p_resend_count,
    log_received = p_log_received,
    confirm_received = p_confirm_received,
    receive_count = p_receive_count,
    rereceive_count = p_rereceive_count
    where user_id = p_user_id;
  commit work
end
