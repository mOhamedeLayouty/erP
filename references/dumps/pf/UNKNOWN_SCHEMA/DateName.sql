-- PF: UNKNOWN_SCHEMA.DateName
-- proc_id: 366
-- generated_at: 2025-12-29T13:53:28.798Z

create function DBA.DateName( in typ varchar(10),in adt DATETIME ) 
returns varchar(15)
begin
  return(dayname(adt))
end
