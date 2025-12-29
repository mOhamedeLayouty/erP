-- PF: UNKNOWN_SCHEMA.sa_set_tracing_level
-- proc_id: 206
-- generated_at: 2025-12-29T13:53:28.752Z

create procedure dbo.sa_set_tracing_level( 
  in level integer,
  in specified_scope long varchar default null,
  in specified_name long varchar default null,
  in do_commit tinyint default 1 ) 
begin
  call dbo.sp_checkperms('PROFILE');
  truncate table sa_diagnostic_tracing_level;
  if level = 0 then
    return
  end if;
  if specified_scope is null then set specified_scope = 'database' end if;
  insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( 'database',null,'volatile_statistics','sample_every',1000,1 ) ;
  insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( 'database',null,'nonvolatile_statistics','sample_every',60000,1 ) ;
  insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values
    ( if specified_scope in( 'connection_number','connection_name' ) then specified_scope else 'database' endif,if specified_scope in( 'connection_name','connection_number' ) then specified_name else null endif,
    'connection_statistics','sample_every',60000,1 ) ;
  if level = 1 then
    insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( specified_scope,specified_name,'statements','sample_every',5000,1 ) ;
    return
  end if;
  if level = 2 then
    insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( specified_scope,specified_name,'statements',null,null,1 ) ;
    insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( specified_scope,specified_name,'plans_with_statistics','sample_every',5000,1 ) ;
    return
  end if;
  if level = 3 then
    insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( specified_scope,specified_name,'blocking',null,null,1 ) ;
    insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( specified_scope,specified_name,'deadlock',null,null,1 ) ;
    insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( specified_scope,specified_name,'statements_with_variables',null,null,1 ) ;
    insert into sa_diagnostic_tracing_level( scope,identifier,trace_type,trace_condition,value,enabled ) values( specified_scope,specified_name,'plans_with_statistics','sample_every',2000,1 ) ;
    return
  end if;
  if do_commit = 1 then
    commit work
  end if
end
