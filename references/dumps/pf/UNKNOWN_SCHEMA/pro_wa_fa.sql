-- PF: UNKNOWN_SCHEMA.pro_wa_fa
-- proc_id: 414
-- generated_at: 2025-12-29T13:53:28.811Z

create procedure DBA.pro_wa_fa( in s_id char(3),in i_qty integer,in s_paper char(8),in s_hld char(12),in s_parent char(12),in d_price decimal(20,3) ) 
begin
  //
  declare i_bal integer;
  //
  select st_walet_fa.st_s_bal
    into i_bal from st_walet_fa
    where(st_walet_fa.paper_code = s_paper)
    and(st_walet_fa.hld_parent = s_parent)
    and(st_walet_fa.hld_code = s_hld);
  case s_id when 'ADD' then
    set i_bal = i_bal+i_qty;
    update st_walet_fa
      set st_walet_fa.st_s_bal = i_bal,
      st_walet_fa.st_bal = i_bal-st_walet_fa.st_lock
      where(st_walet_fa.paper_code = s_paper)
      and(st_walet_fa.hld_code = s_hld) when 'MIN' then
    set i_bal = i_bal-i_qty;
    update st_walet_fa
      set st_walet_fa.st_s_bal = i_bal,
      st_walet_fa.st_bal = i_bal-st_walet_fa.st_lock
      where(st_walet_fa.paper_code = s_paper)
      and(st_walet_fa.hld_code = s_hld) when 'INS' then
    insert into st_walet_fa( paper_code,
      hld_code,
      hld_parent,price,
      st_s_bal,st_lock,
      st_bal ) values
      ( s_paper,s_hld,
      s_parent,d_price,
      i_qty,0,
      i_qty ) 
  end case
end
