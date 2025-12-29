-- PF: UNKNOWN_SCHEMA.rs_update_threads
-- proc_id: 310
-- generated_at: 2025-12-29T13:53:28.783Z

create procedure rs_systabgroup.rs_update_threads( in @rs_id integer,in @rs_seq integer ) 
begin
  update rs_systabgroup.rs_threads set seq = @rs_seq where id = @rs_id
end
