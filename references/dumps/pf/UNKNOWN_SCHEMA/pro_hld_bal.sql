-- PF: UNKNOWN_SCHEMA.pro_hld_bal
-- proc_id: 415
-- generated_at: 2025-12-29T13:53:28.811Z

create procedure DBA.pro_hld_bal( in hld_id char(12),in bal_id char(2),in mode_id char(3),in dec_num decimal(20,3) ) 
begin
  declare MyDb decimal(20,3);
  declare MyCr decimal(20,3);
  select holder.debit,holder.credit into MyDb,MyCr
    from holder
    where holder.hld_code = hld_id;
  if(bal_id = 'DB') or(bal_id = 'BU') or(bal_id = 'DD') then
    if mode_id = 'MIN' then
      set MyDb = MyDb-dec_num
    else
      set MyDb = MyDb+dec_num
    end if
  elseif(bal_id = 'CR') or(bal_id = 'SA') or(bal_id = 'CC') then
    if mode_id = 'MIN' then
      set MyCr = MyCr-dec_num
    else
      set MyCr = MyCr+dec_num
    end if end if;
  update holder
    set holder.debit = MyDb,
    holder.credit = MyCr,
    holder.e_bal = (holder.o_bal+(MyCr-MyDb))
    where holder.hld_code = hld_id
end
