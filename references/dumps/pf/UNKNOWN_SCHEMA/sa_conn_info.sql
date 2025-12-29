-- PF: UNKNOWN_SCHEMA.sa_conn_info
-- proc_id: 61
-- generated_at: 2025-12-29T13:53:28.708Z

create procedure dbo.sa_conn_info( in connidparm integer default null ) 
result( 
  Number integer,
  Name varchar(255),
  Userid varchar(255),
  DBNumber integer,
  LastReqTime varchar(255),
  ReqType varchar(255),
  CommLink varchar(255),
  NodeAddr varchar(255),
  ClientPort integer,
  ServerPort integer,
  BlockedOn integer,
  LockRowID unsigned bigint,
  LockIndexID integer,
  LockTable varchar(255),
  UncommitOps integer,
  ParentConnection integer ) dynamic result sets 1
begin
  select Number as Number,
    connection_property('Name',Number) as Name,
    connection_property('Userid',Number) as Userid,
    connection_property('DBNumber',Number) as DBNumber,
    connection_property('LastReqTime',Number) as LastReqTime,
    connection_property('ReqType',Number) as ReqType,
    connection_property('CommLink',Number) as CommLink,
    connection_property('NodeAddress',Number) as NodeAddr,
    connection_property('ClientPort',Number) as ClientPort,
    connection_property('ServerPort',Number) as ServerPort,
    connection_property('BlockedOn',Number) as BlockedOn,
    connection_property('LockRowID',Number) as LockRowID,
    if(connection_property('LockIndexID',Number) = '') then
      null
    else
      connection_property('LockIndexID',Number)
    endif as LockIndexID,
    if(connection_property('LockTableOID',Number) = '0') then
      ''
    else
      (select u.user_name || '.' || t.table_name
        from SYS.SYSTAB as t
          join SYS.SYSUSER as u on(t.creator = u.user_id)
        where t.object_id = connection_property('LockTableOID',Number))
    endif as LockTable,
    connection_property('UncommitOp',Number) as UncommitOps,
    connection_property('ParentConnection',Number) as ParentConnection
    from dbo.sa_conn_list(connidparm,null)
end
