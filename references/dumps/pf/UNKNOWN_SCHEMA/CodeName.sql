-- PF: UNKNOWN_SCHEMA.CodeName
-- proc_id: 358
-- generated_at: 2025-12-29T13:53:28.796Z

create function DBA.CodeName( in id char(1),in thecode char(12) ) 
returns char(50)
begin
  declare TheName char(50);
  set thecode = Trim(thecode);
  case id when 'H' then
    //
    select holder.hld_name
      into TheName from holder
      where holder.hld_code = thecode when 'P' then
    select paper.paper_name
      into TheName from paper
      where paper.paper_code = thecode when 'B' then
    select broker.b_name
      into TheName from broker
      where broker.b_code = thecode
  end case;
  //
  return(TheName)
end
