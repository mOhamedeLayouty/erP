-- PF: UNKNOWN_SCHEMA.fun_auto
-- proc_id: 360
-- generated_at: 2025-12-29T13:53:28.796Z

create function DBA.fun_auto( in id char(2) ) 
returns integer
begin
  declare TheNum integer;
  //
  select doc_count.inv_num
    into TheNum from doc_count
    where doc_count.col_id = id;
  //
  if @@error = 0 then
    set TheNum = TheNum+1;
    //
    update doc_count
      set inv_num = TheNum
      where doc_count.col_id = id
  end if;
  //
  set TheNum = IsNull(TheNum,0);
  //
  return(TheNum)
end
