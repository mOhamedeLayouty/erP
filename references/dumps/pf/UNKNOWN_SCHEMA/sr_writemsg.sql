-- PF: UNKNOWN_SCHEMA.sr_writemsg
-- proc_id: 280
-- generated_at: 2025-12-29T13:53:28.774Z

create procedure dbo.sr_writemsg( 
  in @uname varchar(128),
  in @filename varchar(1000),
  in @message long binary ) 
begin
  declare err_notinitialized exception for sqlstate value '99101';
  declare err_dbremoteerror exception for sqlstate value '99102';
  if varexists('@gv_dbremote_uname') = 0 then
    signal err_notinitialized
  end if;
  delete from dbo.gtt_dbremote_temp;
  insert into dbo.gtt_dbremote_temp
    select attr,value
      from dbo.sr_send_msgfile_ws(
        @gv_dbremote_url,
        @uname,
        @filename,
        @message,
        @gv_dbremote_cert,
        @gv_dbremote_proxy,
        @gv_dbremote_clport);
  set @gv_dbremote_status = (select value from dbo.gtt_dbremote_temp where attr = 'X-DBREMOTE-ERR');
  set @gv_dbremote_errmsg = (select value from dbo.gtt_dbremote_temp where attr = 'X-DBREMOTE-MSG');
  if @gv_dbremote_status is null or @gv_dbremote_status <> '0' then
    signal err_dbremoteerror
  end if
exception
  when err_dbremoteerror then
    resignal
  when others then
    select sqlcode,errormsg()
      into @gv_dbremote_status,@gv_dbremote_errmsg;
    resignal
end
