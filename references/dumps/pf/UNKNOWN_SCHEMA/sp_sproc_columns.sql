-- PF: UNKNOWN_SCHEMA.sp_sproc_columns
-- proc_id: 25
-- generated_at: 2025-12-29T13:53:28.698Z

create procedure dbo.sp_sproc_columns( 
  in @sp_name char(128),
  in @sp_owner char(128) default null,
  in @sp_qualifier char(128) default null,
  in @column_name char(1024) default null ) 
result( 
  procedure_qualifier char(128),
  procedure_owner char(128),
  procedure_name char(128),
  column_name char(128),
  column_type varchar(5),
  data_type smallint,
  type_name char(128),
  "precision" integer,
  length integer,
  scale smallint,
  radix smallint,
  nullable smallint,
  remarks varchar(254),
  ss_data_type smallint,
  colid unsigned integer ) dynamic result sets 1
begin
  declare @full_sp_name long varchar;
  declare objid integer;
  if @sp_owner is null then
    set @full_sp_name = @sp_name
  else
    set @full_sp_name = @sp_owner || '.' || @sp_name
  end if;
  if @column_name is null then
    set @column_name = '%'
  end if;
  set objid = object_id(@full_sp_name);
  select current database as procedure_qualifier,
    user_name as procedure_owner,
    proc_name as procedure_name,
    (if pp.parm_type = 4 then '@RETURN_VALUE' else parm_name endif) as column_name,
    (case when pp.parm_mode_in = 'Y' and pp.parm_mode_out = 'N' then 'IN'
    when pp.parm_mode_in = 'N' and pp.parm_mode_out = 'Y' then 'OUT'
    when pp.parm_mode_in = 'Y' and pp.parm_mode_out = 'Y' then 'INOUT'
    else null
    end) as column_type,
    d.type_id as data_type,
    domain_name as type_name,
    d."precision",
    width as length,
    scale,
    (if locate(d.domain_name,'char') = 0
    and locate(d.domain_name,'binary') = 0
    and locate(d.domain_name,'time') = 0
    and locate(d.domain_name,'date') = 0 then
      10 else null endif) as radix,
    (if "default" is not null then 1 else 0 endif) as nullable,
    null as remarks,
    pp.domain_id as ss_data_type,
    parm_id as colid
    from SYS.SYSPROCEDURE as p,SYS.SYSPROCPARM as pp,SYS.SYSDOMAIN as d
      ,SYS.SYSUSER as u
    where p.object_id = objid
    and p.proc_id = pp.proc_id
    and pp.domain_id = d.domain_id
    and p.creator = u.user_id
    and pp.parm_type in( 0,4 ) 
    and parm_name like @column_name
    order by parm_id asc
end
