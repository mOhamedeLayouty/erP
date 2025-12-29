-- PF: UNKNOWN_SCHEMA.sr_connect
-- proc_id: 277
-- generated_at: 2025-12-29T13:53:28.773Z

create procedure dbo.sr_connect( 
  in @uname varchar(128),
  in @url varchar(1000),
  in @cert long varchar default null,
  in @proxy varchar(1000) default null,
  in @clport varchar(10) default null ) 
begin
  declare err_dbremoteerror exception for sqlstate value '99102';
  if "right"(@url,1) = '/' then
    set @url = "left"(@url,length(@url)-1)
  end if;
  create or replace variable @gv_dbremote_uname varchar(128);
  create or replace variable @gv_dbremote_url varchar(1000);
  create or replace variable @gv_dbremote_cert long varchar;
  create or replace variable @gv_dbremote_proxy varchar(1000);
  create or replace variable @gv_dbremote_clport varchar(10);
  create or replace variable @gv_dbremote_status varchar(10);
  create or replace variable @gv_dbremote_errmsg long varchar;
  set @gv_dbremote_uname = @uname;
  set @gv_dbremote_url = @url;
  set @gv_dbremote_cert = @cert;
  set @gv_dbremote_proxy = @proxy;
  set @gv_dbremote_clport = @clport;
  delete from dbo.gtt_dbremote_temp;
  insert into dbo.gtt_dbremote_temp
    select attr,value
      from dbo.sr_ping_ws(
        @gv_dbremote_url,
        @gv_dbremote_uname,
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
    drop variable if exists @gv_dbremote_uname;
    drop variable if exists @gv_dbremote_url;
    drop variable if exists @gv_dbremote_cert;
    drop variable if exists @gv_dbremote_proxy;
    drop variable if exists @gv_dbremote_clport;
    resignal
  when others then
    drop variable if exists @gv_dbremote_uname;
    drop variable if exists @gv_dbremote_url;
    drop variable if exists @gv_dbremote_cert;
    drop variable if exists @gv_dbremote_proxy;
    drop variable if exists @gv_dbremote_clport;
    drop variable if exists @gv_dbremote_status;
    drop variable if exists @gv_dbremote_errmsg;
    resignal
end
