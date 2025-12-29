-- PF: UNKNOWN_SCHEMA.pro_status
-- proc_id: 416
-- generated_at: 2025-12-29T13:53:28.812Z

create procedure DBA.pro_status( in s_id char(1),in s_fr char(15),in s_to char(15),in s_paper char(6) ) 
begin
  update trade_paper_son set trade_paper_son.status = s_id
    where((trade_paper_son.st_fr = s_fr)
    and(trade_paper_son.st_to = s_to)
    and(trade_paper_son.paper_code = s_paper)
    and("Left"(trade_paper_son.op_type,1) = 'B'))
end
