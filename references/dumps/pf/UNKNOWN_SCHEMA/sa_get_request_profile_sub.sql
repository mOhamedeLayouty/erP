-- PF: UNKNOWN_SCHEMA.sa_get_request_profile_sub
-- proc_id: 191
-- generated_at: 2025-12-29T13:53:28.747Z

create procedure dbo.sa_get_request_profile_sub( in preliminary integer ) 
begin
  declare local temporary table satmp_request_uniq(
    stmt_id integer not null default autoincrement,
    prefix long varchar not null,
    primary key(stmt_id),
    ) in SYSTEM not transactional;
  -- Create a summary table with one row for each distinct statement.
  insert into satmp_request_uniq( prefix ) 
    select distinct prefix
      from dbo.satmp_request_time
      where prefix is not null;
  commit work;
  create index uniq_prefix on satmp_request_uniq(prefix);
  update dbo.satmp_request_time as r
    set r.stmt_id = u.stmt_id from
    dbo.satmp_request_time as r,satmp_request_uniq as u
    where r.prefix = u.prefix;
  commit work;
  if preliminary = 1 then
    insert into dbo.satmp_request_profile
      select stmt_id,
        count(),
        0,
        0,
        0,
        ''
        from dbo.satmp_request_time as r
        where stmt_id <> 0
        and substr(stmt,1,6) in( 'SELECT','UPDATE' ) 
        group by stmt_id
        having count() = 1
  else
    insert into dbo.satmp_request_profile
      select stmt_id,
        count(),
        sum(millisecs),
        avg(millisecs),
        max(millisecs),
        (select prefix from satmp_request_uniq as u
          where u.stmt_id = r.stmt_id)
        from dbo.satmp_request_time as r
        where stmt_id <> 0
        group by stmt_id
  end if;
  commit work
end
