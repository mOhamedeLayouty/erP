-- PF: UNKNOWN_SCHEMA.pro_order
-- proc_id: 418
-- generated_at: 2025-12-29T13:53:28.812Z

create procedure DBA.pro_order( in s_id char(3),in s_ord_id char(13),in i_qty integer ) 
begin
  //
  declare i_done integer;
  //
  select ord_fa.q_done
    into i_done from ord_fa
    where ord_fa.ord_t_num = s_ord_id;
  //
  case s_id when 'ADD' then
    set i_done = i_done+i_qty when 'MIN' then
    set i_done = i_done-i_qty
  end case;
  //
  update ord_fa
    set ord_fa.q_done = i_done,
    ord_fa.q_valid = ord_fa.q_req-i_done
    where ord_fa.ord_t_num = s_ord_id
//
end
