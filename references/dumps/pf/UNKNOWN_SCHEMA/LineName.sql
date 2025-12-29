-- PF: UNKNOWN_SCHEMA.LineName
-- proc_id: 354
-- generated_at: 2025-12-29T13:53:28.795Z

create function DBA.LineName( in paper_id char(8) ) 
returns char(45)
begin
  declare Pa_Name char(50);
  select paper.paper_name
    into Pa_Name from paper
    where paper.paper_code = paper_id;
  return(Pa_Name)
end
