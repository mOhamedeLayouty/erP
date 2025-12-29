-- PF: UNKNOWN_SCHEMA.rs_update_lastcommit
-- proc_id: 307
-- generated_at: 2025-12-29T13:53:28.782Z

create procedure rs_systabgroup.rs_update_lastcommit( 
  in @origin integer,
  in @origin_qid binary(36),
  in @secondary_qid binary(36),
  in @origin_time datetime ) 
begin
  update rs_systabgroup.rs_lastcommit
    set origin_qid = @origin_qid,
    secondary_qid = @secondary_qid,
    origin_time = @origin_time,
    commit_time = getdate()
    where origin = @origin;
  if(@@rowcount = 0) then
    insert into rs_systabgroup.rs_lastcommit( origin,origin_qid,secondary_qid,
      origin_time,commit_time ) values
      ( @origin,@origin_qid,@secondary_qid,
      @origin_time,getdate() ) 
  end if
end
