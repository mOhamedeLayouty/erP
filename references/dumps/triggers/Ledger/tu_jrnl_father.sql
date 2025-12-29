-- TRIGGER: Ledger.tu_jrnl_father
-- ON TABLE: Ledger.jrnl_father
-- generated_at: 2025-12-29T13:52:33.695Z

create trigger tu_jrnl_father before update on
ledger.jrnl_father
referencing old as old_st new as new_st --V2 link by company_code
for each row
begin
  if update(flag) then
    update jrnl_son
      set jrnl_son.flag = new_st.flag
      where jrnl_son.jrnl_no = new_st.jrnal_no
      and jrnl_son.company_code = new_st.company_code
  end if
end
