-- PF: UNKNOWN_SCHEMA.sp_stored_procedures
-- proc_id: 27
-- generated_at: 2025-12-29T13:53:28.699Z

create procedure dbo.sp_stored_procedures( 
  in @sp_name char(1024) default null,
  in @sp_owner char(1024) default null,
  in @sp_qualifier char(1024) default null ) 
result( 
  procedure_qualifier char(128),
  procedure_owner char(128),
  procedure_name char(128),
  num_input_params integer,
  num_output_params integer,
  num_result_sets integer,
  remarks varchar(254) ) dynamic result sets 1
begin
  if @sp_name is null then
    set @sp_name = '%'
  else
    if(@sp_owner is null) and(charindex('%',@sp_name) = 0) then
      if exists(select * from SYS.SYSPROCEDURE,SYS.SYSUSER
          where creator = user_id
          and user_name = current user
          and proc_name = @sp_name) then
        set @sp_owner = current user
      end if
    end if end if;
  if @sp_owner is null then
    set @sp_owner = '%'
  end if;
  select current database,
    user_name,
    proc_name,
    (select count() from SYS.SYSPROCPARM
      where parm_mode_in = 'Y'
      and parm_type = 0
      and proc_id = p.proc_id),
    (select count() from SYS.SYSPROCPARM
      where parm_mode_out = 'Y'
      and parm_type = 0
      and proc_id = p.proc_id),
    if exists(select * from SYS.SYSPROCPARM
      where parm_type = 1
      and proc_id = p.proc_id) then 1 else 0 endif,
    null
    from SYS.SYSPROCEDURE as p,SYS.SYSUSER as u
    where proc_name like @sp_name
    and user_name like @sp_owner
    and p.creator = u.user_id
end
