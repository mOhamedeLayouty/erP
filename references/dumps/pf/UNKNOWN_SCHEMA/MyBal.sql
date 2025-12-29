-- PF: UNKNOWN_SCHEMA.MyBal
-- proc_id: 356
-- generated_at: 2025-12-29T13:53:28.795Z

create function DBA.MyBal( in Id char(2),in Id_Code char(12) ) 
returns decimal(20,3)
begin
  declare MyNum decimal(20,3);
  declare in1 char(2);
  declare in2 char(2);
  declare in3 char(2);
  //
  if ID = 'CR' then
    set in1 = 'CR';
    set in2 = 'SA';
    set in3 = 'CC'
  else
    set in1 = 'DB';
    set in2 = 'BU';
    set in3 = 'DD'
  end if;
  //
  select Sum(doc_fa.doc_tot)
    into MyNum from doc_fa
    where doc_fa.hld_code = id_code
    and doc_fa.doc_type in( in1,in2,in3 ) ;
  //
  return(MyNum)
end
