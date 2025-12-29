-- PF: UNKNOWN_SCHEMA.rs_get_lastcommit
-- proc_id: 306
-- generated_at: 2025-12-29T13:53:28.781Z

create procedure rs_systabgroup.rs_get_lastcommit()
begin
  select origin,origin_qid,secondary_qid
    from rs_systabgroup.rs_lastcommit
end
