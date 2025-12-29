-- PF: UNKNOWN_SCHEMA.sa_performance_diagnostics
-- proc_id: 254
-- generated_at: 2025-12-29T13:53:28.767Z

create procedure dbo.sa_performance_diagnostics()
result( 
  Number integer,
  Name varchar(255),
  Userid varchar(255),
  DBNumber integer,
  LoginTime timestamp,
  TransactionStartTime timestamp,
  LastReqTime timestamp,
  ReqType varchar(255),
  ReqStatus varchar(255),
  ReqTimeUnscheduled double,
  ReqTimeActive double,
  ReqTimeBlockIO double,
  ReqTimeBlockLock double,
  ReqTimeBlockContention double,
  ReqCountUnscheduled integer,
  ReqCountActive integer,
  ReqCountBlockIO integer,
  ReqCountBlockLock integer,
  ReqCountBlockContention integer,
  LastIdle integer,
  BlockedOn integer,
  UncommitOp integer,
  CurrentProcedure varchar(255),
  EventName varchar(255),
  CurrentLineNumber integer,
  LastStatement long varchar,
  LastPlanText long varchar,
  AppInfo long varchar,
  SnapshotCount integer,
  LockCount integer ) dynamic result sets 1
internal name 'sa_performance_diagnostics'
