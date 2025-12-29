-- PF: UNKNOWN_SCHEMA.MyBefor
-- proc_id: 357
-- generated_at: 2025-12-29T13:53:28.796Z

create function DBA.MyBefor( in acc_id char(12),in da_fr char(10) default '1901-01-01' ) 
returns decimal(20,3)
begin
  declare MyCR decimal(20,3);
  declare MyDB decimal(20,3);
  declare Mall decimal(20,3);
  select SUM(doc_tot)
    into MyCR from doc_fa
    where((doc_fa.hld_code = acc_id)
    and(doc_fa.doc_type in( 'CR','SA','CC' ) )
    and(doc_fa.doc_due = doc_fa.curr_sub_tot)
    and(doc_fa.doc_date < da_fr));
  select SUM(doc_tot)
    into MyDB from doc_fa
    where((doc_fa.hld_code = acc_id)
    and(doc_fa.doc_type in( 'DB','BU','DD' ) )
    and(doc_fa.doc_due = doc_fa.curr_sub_tot)
    and(doc_fa.doc_date < da_fr));
  set Mall = MyCR-MyDB;
  return(Mall)
end
