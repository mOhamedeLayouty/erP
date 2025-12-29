-- PF: UNKNOWN_SCHEMA.sr_getlasterr
-- proc_id: 283
-- generated_at: 2025-12-29T13:53:28.774Z

create procedure dbo.sr_getlasterr( 
  out @status varchar(10),
  out @errmsg long varchar ) 
begin
  if varexists('@gv_dbremote_status') = 0 or varexists('@gv_dbremote_errmsg') = 0 then
    begin
      declare err_notinitialized exception for sqlstate value '99101';
      signal err_notinitialized
    end
  end if;
  set @status = @gv_dbremote_status;
  set @errmsg = @gv_dbremote_errmsg;
  if varexists('@gv_dbremote_uname') = 0 then
    drop variable if exists @gv_dbremote_status;
    drop variable if exists @gv_dbremote_errmsg
  end if
exception
  when others then
end
