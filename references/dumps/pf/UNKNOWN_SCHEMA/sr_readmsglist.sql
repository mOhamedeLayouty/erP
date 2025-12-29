-- PF: UNKNOWN_SCHEMA.sr_readmsglist
-- proc_id: 278
-- generated_at: 2025-12-29T13:53:28.773Z

create procedure dbo.sr_readmsglist()
result( fname varchar(1000),size varchar(20),cdt timestamp,mdt timestamp ) dynamic result sets 1
begin
  declare err_notinitialized exception for sqlstate value '99101';
  declare err_dbremoteerror exception for sqlstate value '99102';
  declare @body long varchar;
  if varexists('@gv_dbremote_uname') = 0 then
    signal err_notinitialized
  end if;
  delete from dbo.gtt_dbremote_temp;
  insert into dbo.gtt_dbremote_temp
    select attr,value
      into dbo.gtt_dbremote_temp
      from dbo.sr_read_msglist_ws(
        @gv_dbremote_url,
        @gv_dbremote_uname,
        @gv_dbremote_cert,
        @gv_dbremote_proxy,
        @gv_dbremote_clport);
  set @gv_dbremote_status = (select value from dbo.gtt_dbremote_temp where attr = 'X-DBREMOTE-ERR');
  set @gv_dbremote_errmsg = (select value from dbo.gtt_dbremote_temp where attr = 'X-DBREMOTE-MSG');
  if @gv_dbremote_status is null or @gv_dbremote_status <> '0' then
    signal err_dbremoteerror
  end if;
  set @body = (select value from dbo.gtt_dbremote_temp where attr = 'Body');
  select fname,size,cdt,mdt
    from openxml(@body,'/root/e') with(fname varchar(1000) '@fname',size varchar(20) '@size',cdt timestamp '@cdt',mdt timestamp '@mdt')
exception
  when err_dbremoteerror
  then
    resignal
  when others then
    select sqlcode,errormsg()
      into @gv_dbremote_status,@gv_dbremote_errmsg;
    resignal
end
