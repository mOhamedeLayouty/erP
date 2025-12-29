-- PF: UNKNOWN_SCHEMA.sp_helptext
-- proc_id: 17
-- generated_at: 2025-12-29T13:53:28.696Z

create procedure dbo.sp_helptext( in @objname char(257) default null ) 
result( text long varchar ) dynamic result sets 1
begin
  declare objid integer;
  declare objtype char(2);
  declare txt long varchar;
  set objid = object_id(@objname);
  if objid is null then
    return
  end if;
  select type into objtype from dbo.sysobjects where id = objid;
  if objtype = 'V' then
    select view_def
      into txt from SYS.SYSVIEW
      where view_object_id = objid
  else
    if objtype = 'P' then
      select proc_defn
        into txt from SYS.SYSPROCEDURE
        where object_id = objid
    else
      select trigger_defn
        into txt from SYS.SYSTRIGGER
        where object_id = objid
    end if end if;
  if txt is null then
    return
  end if;
  select replace(row_value,"char"(13),'') as text
    from dbo.sa_split_list(txt,'\x0A')
    order by line_num asc
end
