-- PF: UNKNOWN_SCHEMA.sp_setreplicate
-- proc_id: 156
-- generated_at: 2025-12-29T13:53:28.738Z

create procedure dbo.sp_setreplicate( 
  in @obj_name char(128),
  in @true_false char(5) ) 
begin
  declare type char(3);
  declare type_crsr dynamic scroll cursor for
    select type
      from dbo.sysobjects
      where name = @obj_name;
  if exists(select * from dbo.sysobjects
      where name = @obj_name) then
    set type = '';
    open type_crsr;
    fetch next type_crsr into type;
    if sqlcode = 0 then
      set type = rtrim(type)
    end if;
    close type_crsr;
    if lcase(type) = 'U' then
      call dbo.sp_setreptable(@obj_name,@true_false)
    elseif lcase(type) = 'P' then
      call dbo.sp_setrepproc(@obj_name,@true_false)
    end if
  else
    raiserror 17969 'No user table or procedure named ''' || @obj_name || ''' exists in this database'
  end if
end
