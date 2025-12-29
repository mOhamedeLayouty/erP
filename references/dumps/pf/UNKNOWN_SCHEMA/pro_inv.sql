-- PF: UNKNOWN_SCHEMA.pro_inv
-- proc_id: 413
-- generated_at: 2025-12-29T13:53:28.811Z

create procedure DBA.pro_inv( in up_id char(1),in doc_id char(13),in id integer,in dec_num decimal(20,3) ) 
begin
  declare MyNum decimal(20,3);
  if id = 0 then
    set MyNum = dec_num*-1
  else
    set MyNum = dec_num
  end if;
  if up_id = 'S' then
    update doc_fa
      set doc_fa.doc_due = doc_fa.doc_due+MyNum
      where doc_fa.doc_t_num = doc_id
  else
    update doc_fa
      set doc_fa.doc_trd = doc_fa.doc_trd+MyNum
      where doc_fa.doc_t_num = doc_id
  end if
end
