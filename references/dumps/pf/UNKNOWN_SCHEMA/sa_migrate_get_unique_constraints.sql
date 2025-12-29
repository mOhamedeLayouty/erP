-- PF: UNKNOWN_SCHEMA.sa_migrate_get_unique_constraints
-- proc_id: 316
-- generated_at: 2025-12-29T13:53:28.785Z

create function dbo.sa_migrate_get_unique_constraints( in tid integer ) 
returns varchar(32000)
begin
  declare unique_constraints varchar(32000);
  declare one_unique_constraint varchar(32000);
  declare err_notfound exception for sqlstate value '02000';
  declare curs dynamic scroll cursor for select distinct 'UNIQUE( ' || list(c.column_name) || ')'
      from SYS.SYSCOLUMN as c,SYS.SYSINDEX as i,SYS.SYSIXCOL as ic
      where i.table_id = tid
      and i.table_id = c.table_id
      and ic.table_id = c.table_id
      and c.column_id = ic.column_id
      and i.table_id = ic.table_id
      and i."unique" = 'U'
      and i.index_id = ic.index_id
      group by i.index_id;
  open curs;
  set unique_constraints = null;
  UniqueLoop: loop
    fetch next curs into one_unique_constraint;
    if sqlstate = err_notfound then leave UniqueLoop end if;
    set unique_constraints = unique_constraints || ', ' || one_unique_constraint
  end loop UniqueLoop;
  close curs;
  return unique_constraints
end
