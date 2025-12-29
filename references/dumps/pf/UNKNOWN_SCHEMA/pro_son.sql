-- PF: UNKNOWN_SCHEMA.pro_son
-- proc_id: 412
-- generated_at: 2025-12-29T13:53:28.811Z

create procedure DBA.pro_son( in i_line integer,in d_date date,
  in s_id char(13) default null ) 
begin
  update trade_son
    set trade_son.b_t_inv = s_id
    where(trade_son.line_no = i_line)
    and(trade_son.op_date = d_date)
end
