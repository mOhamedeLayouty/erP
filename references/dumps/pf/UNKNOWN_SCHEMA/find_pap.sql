-- PF: UNKNOWN_SCHEMA.find_pap
-- proc_id: 355
-- generated_at: 2025-12-29T13:53:28.795Z

create function dba.find_pap( in s_paper char(8),in s_fr char(15),in s_to char(15) ) 
returns char(1)
begin
  declare s_ret char(1);
  declare s_pos char(1);
  declare i_pos_fr integer;
  declare i_pos_to integer;
  declare ii_fr double;
  declare ii_to double;
  //----------------------------------------//
  select paper.sep_pos
    into s_pos from paper
    where paper.paper_code = s_paper;
  //----------------------------------------//
  set i_pos_fr = Locate(s_fr,'/');
  set i_pos_to = Locate(s_to,'/');
  if i_pos_fr > 0 then
    if s_pos = '0' then
      set ii_fr = cast((SubStr(s_fr,1,i_pos_fr-1)) as integer);
      set ii_to = cast((SubStr(s_to,1,i_pos_fr-1)) as integer)
    else
      set ii_fr = cast((SubStr(s_fr,i_pos_to+1)) as integer);
      set ii_to = cast((SubStr(s_to,i_pos_to+1)) as integer)
    end if
  else set ii_fr = cast(s_fr as integer);
    set ii_to = cast(s_to as integer)
  end if;
  //----------------------------------------//
  if exists(select 1 from vi_walet
      where(vi_walet.paper_code = s_paper)
      and(ii_fr between vi_walet.i_fr and vi_walet.i_to)) then
    set s_ret = 'T'
  else
    set s_ret = 'F'
  end if;
  //----------------------------------------//
  return(s_ret)
end
