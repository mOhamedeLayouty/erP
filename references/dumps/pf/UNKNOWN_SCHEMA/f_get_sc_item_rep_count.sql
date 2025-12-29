-- PF: UNKNOWN_SCHEMA.f_get_sc_item_rep_count
-- proc_id: 448
-- generated_at: 2025-12-29T13:53:28.821Z

create function DBA.f_get_sc_item_rep_count( in as_item_id varchar(50),in an_center_id integer default 1 ) 
returns integer
begin
  declare ll_count integer;
  select count() into ll_count from dba.sc_item_replace
    where item_code = as_item_id and service_center = an_center_id;
  return ll_count
end
