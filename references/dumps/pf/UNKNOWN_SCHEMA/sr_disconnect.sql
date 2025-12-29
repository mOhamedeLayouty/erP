-- PF: UNKNOWN_SCHEMA.sr_disconnect
-- proc_id: 282
-- generated_at: 2025-12-29T13:53:28.774Z

create procedure dbo.sr_disconnect()
begin
  drop variable if exists @gv_dbremote_uname;
  drop variable if exists @gv_dbremote_url;
  drop variable if exists @gv_dbremote_cert;
  drop variable if exists @gv_dbremote_proxy;
  drop variable if exists @gv_dbremote_clport;
  drop variable if exists @gv_dbremote_status;
  drop variable if exists @gv_dbremote_errmsg
exception
  when others then
end
