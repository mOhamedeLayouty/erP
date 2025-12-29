-- PF: UNKNOWN_SCHEMA.sp_servercaps
-- proc_id: 153
-- generated_at: 2025-12-29T13:53:28.737Z

create procedure dbo.sp_servercaps( in @sname char(64) ) 
begin
  select t2.capid,property('RemoteCapability',t2.capid) as capname,t2.capvalue
    from SYS.SYSSERVER as t1 join SYS.SYSCAPABILITY as t2 on(t1.srvid = t2.srvid)
    where t1.srvname = @sname
    order by t2.capid asc
end
