-- PF: UNKNOWN_SCHEMA.rs_initialize_threads
-- proc_id: 309
-- generated_at: 2025-12-29T13:53:28.782Z

create procedure rs_systabgroup.rs_initialize_threads( in @rs_id integer ) 
begin
  delete from rs_systabgroup.rs_threads where id = @rs_id;
  insert into rs_systabgroup.rs_threads values( @rs_id,0 ) 
end
