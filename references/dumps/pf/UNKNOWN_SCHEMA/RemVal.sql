-- PF: UNKNOWN_SCHEMA.RemVal
-- proc_id: 353
-- generated_at: 2025-12-29T13:53:28.795Z

create function DBA.RemVal( in DocId char(13) ) 
returns char(50)
begin
  declare TheName char(50);
  select ord_fa.rem
    into TheName from ord_fa
    where ord_fa.ord_t_num = DocId;
  return(TheName)
end
