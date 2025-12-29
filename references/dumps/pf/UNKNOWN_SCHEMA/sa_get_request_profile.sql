-- PF: UNKNOWN_SCHEMA.sa_get_request_profile
-- proc_id: 192
-- generated_at: 2025-12-29T13:53:28.747Z

create procedure dbo.sa_get_request_profile( 
  in filename long varchar default null,
  in conn_id unsigned integer default 0,
  in first_file integer default-1,
  in num_files integer default 1 ) 
begin
  declare commit_cnt integer;
  declare rollback_cnt integer;
  declare commit_ms integer;
  declare rollback_ms integer;
  truncate table dbo.satmp_request_profile;
  call dbo.sa_get_request_times(filename,conn_id,first_file,num_files);
  select isnull(count(),0),isnull(sum(millisecs),0)
    into commit_cnt,commit_ms
    from dbo.satmp_request_time
    where substr(stmt,1,6) = 'COMMIT';
  select isnull(count(),0),isnull(sum(millisecs),0)
    into rollback_cnt,rollback_ms
    from dbo.satmp_request_time
    where substr(stmt,1,8) = 'ROLLBACK';
  update dbo.satmp_request_time
    set stmt = ltrim(stmt)
    where substr(stmt,1,1) = ' ';
  commit work;
  -- Remove statements that are not of interest.
  delete from dbo.satmp_request_time
    where(substr(stmt,1,6) = 'COMMIT'
    or substr(stmt,1,8) = 'ROLLBACK');
  commit work;
  -- Calculate a "prefix" for each statement which should be identical
  -- for statements which are similar.
  update dbo.satmp_request_time
    set prefix = substr(stmt,1,locate(stmt,'(')-1)
    where substr(stmt,1,4) = 'CALL'
    and locate(stmt,'(') <> 0;
  update dbo.satmp_request_time
    set prefix = stmt
    where substr(stmt,1,4) = 'CALL'
    and locate(stmt,'(') = 0;
  commit work;
  update dbo.satmp_request_time
    set prefix = substr(stmt,1,locate(stmt,'VALUES')-1)
    where substr(stmt,1,6) = 'INSERT'
    and locate(stmt,'VALUES') <> 0;
  update dbo.satmp_request_time
    set prefix = substr(stmt,1,locate(stmt,'SELECT')-1)
    where substr(stmt,1,6) = 'INSERT'
    and locate(stmt,'SELECT') <> 0;
  commit work;
  update dbo.satmp_request_time
    set prefix = substr(stmt,1,locate(stmt,'WHERE')-1)
    where substr(stmt,1,6) = 'DELETE'
    and locate(stmt,'WHERE') <> 0;
  update dbo.satmp_request_time
    set prefix = stmt
    where substr(stmt,1,6) = 'DELETE'
    and locate(stmt,'WHERE') = 0;
  commit work;
  update dbo.satmp_request_time
    set prefix = substr(stmt,1,locate(stmt,'WHERE')-1)
    where substr(stmt,1,6) = 'UPDATE'
    and locate(stmt,'WHERE') <> 0;
  update dbo.satmp_request_time
    set prefix = stmt
    where substr(stmt,1,6) = 'UPDATE'
    and locate(stmt,'WHERE') = 0;
  commit work;
  update dbo.satmp_request_time
    set prefix = substr(stmt,1,locate(stmt,'WHERE')-1)
    where substr(stmt,1,6) = 'SELECT'
    and locate(stmt,'WHERE') <> 0;
  update dbo.satmp_request_time
    set prefix = stmt
    where substr(stmt,1,6) = 'SELECT'
    and locate(stmt,'WHERE') = 0;
  commit work;
  -- Include other statements (e.g. CREATE/ALTER/DROP/SET)
  update dbo.satmp_request_time
    set prefix = stmt
    where prefix is null;
  commit work;
  -- Summarize.
  call dbo.sa_get_request_profile_sub(1);
  -- For those statements which are unique because they contain values
  -- in the SELECT list or SET list which vary based on time, userid, etc.
  -- attempt to find common instances.
  update dbo.satmp_request_time as r
    set prefix = substr(stmt,1,locate(stmt,'=')) from
    dbo.satmp_request_time as r,dbo.satmp_request_profile as s
    where substr(stmt,1,6) = 'UPDATE'
    and r.stmt_id = s.stmt_id
    and s.uses = 1;
  commit work;
  update dbo.satmp_request_time as r
    set prefix = substr(stmt,1,100) from
    dbo.satmp_request_time as r,dbo.satmp_request_profile as s
    where substr(stmt,1,6) = 'SELECT'
    and r.stmt_id = s.stmt_id
    and s.uses = 1;
  commit work;
  -- Summarize again.
  truncate table dbo.satmp_request_profile;
  call dbo.sa_get_request_profile_sub(0);
  -- Add COMMIT/ROLLBACK info.
  if commit_cnt > 0 then
    insert into dbo.satmp_request_profile( uses,total_ms,avg_ms,max_ms,prefix ) 
      select commit_cnt,
        commit_ms,
        commit_ms/commit_cnt,
        commit_ms/commit_cnt,
        'COMMIT'
  end if;
  if rollback_cnt > 0 then
    insert into dbo.satmp_request_profile( uses,total_ms,avg_ms,max_ms,prefix ) 
      select rollback_cnt,
        rollback_ms,
        rollback_ms/rollback_cnt,
        rollback_ms/rollback_cnt,
        'ROLLBACK'
  end if;
  commit work
end
