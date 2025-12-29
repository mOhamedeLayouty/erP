-- PF: UNKNOWN_SCHEMA.sp_get_last_synchronize_result
-- proc_id: 271
-- generated_at: 2025-12-29T13:53:28.771Z

create procedure dbo.sp_get_last_synchronize_result( 
  in @conn_id integer default null,
  in @complete_only bit default 1 ) 
result( 
  row_id unsigned bigint,
  conn_id unsigned integer,
  result_time timestamp,
  result_type char(128),
  parm_id unsigned integer,
  parm_message long varchar ) dynamic result sets 1
begin
  declare @max_start unsigned bigint;
  declare @max_done unsigned bigint;
  call dbo.sp_checkperms('DBA');
  if @conn_id is null then
    set @conn_id = CONNECTION_PROPERTY('Number')
  end if;
  select max(row_id)
    into @max_start from dbo.synchronize_results
    where conn_id = @conn_id
    and result_type = 'DBSC_EVENTTYPE_SYNC_START';
  if @max_start is null then
    -- No synchs in table
    return
  end if;
  select max(row_id)
    into @max_done from dbo.synchronize_results
    where conn_id = @conn_id
    and result_type = 'DBSC_EVENTTYPE_SYNC_DONE';
  if @max_done is null then
    -- Just one incomplete synch in table
    if @complete_only = 1 then
      return
    end if
  elseif @max_done < @max_start then
    -- last synch in table is not complete
    if @complete_only = 1 then
      -- use last complete synch
      select max(row_id)
        into @max_start from dbo.synchronize_results
        where conn_id = @conn_id
        and row_id < @max_done
        and result_type = 'DBSC_EVENTTYPE_SYNC_START'
    else
      -- use last incomplete synch
      set @max_done = null
    end if
  end if;
  select sr.row_id,sr.conn_id,sr.result_time,sr.result_type,
    sp.parm_id,sp.parm_message
    from dbo.synchronize_results as sr
      left outer join dbo.synchronize_parameters as sp
    where sr.row_id >= @max_start
    and(@max_done is null or sr.row_id <= @max_done)
    and sr.conn_id = @conn_id
    order by sr.row_id asc,sp.parm_id asc
end
