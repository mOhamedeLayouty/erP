-- PF: UNKNOWN_SCHEMA.pro_wa_son
-- proc_id: 417
-- generated_at: 2025-12-29T13:53:28.812Z

create procedure DBA.pro_wa_son( in s_id char(3),in s_fr char(15),in s_to char(15),in s_paper char(8),in s_p_key char(51),in s_hld char(12),in s_parent char(12),in i_grade integer,in i_num integer,in s_lice char(2),in s_cabon char(15),in d_price decimal(15,3) ) 
begin
  //
  case s_id when 'INS' then
    insert into st_walet( st_fr,
      st_to,
      paper_code,
      st_key,
      hld_code,hld_parent,
      st_grade,st_num,
      st_lice,cabon ) values
      ( s_fr,s_to,
      s_paper,
      s_p_key,
      s_hld,s_parent,
      i_grade,i_num,
      s_lice,s_cabon ) when 'DEL' then
    delete from st_walet
      where((st_walet.st_fr = s_fr)
      and(st_walet.st_to = s_to)
      and(st_walet.paper_code = s_paper))
  end case
end
