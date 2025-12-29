-- PF: UNKNOWN_SCHEMA.sa_oledb_table_constraints
-- proc_id: 301
-- generated_at: 2025-12-29T13:53:28.780Z

create procedure dbo.sa_oledb_table_constraints( 
  in inConstraintCatalog char(128) default '',
  in inConstraintSchema char(128) default '',
  in inConstraintName char(128) default '',
  in inTableCatalog char(128) default '',
  in inTableSchema char(128) default '',
  in inTableName char(128) default '',
  in inConstraintType char(11) default '' ) 
result( 
  CONSTRAINT_CATALOG char(128),
  CONSTRAINT_SCHEMA char(128),
  CONSTRAINT_NAME char(128),
  TABLE_CATALOG char(128),
  TABLE_SCHEMA char(128),
  TABLE_NAME char(128),
  CONSTRAINT_TYPE char(11),
  IS_DEFERRABLE bit,
  INITIALLY_DEFERRED bit,
  DESCRIPTION varchar(254) ) dynamic result sets 1
on exception resume
begin
  declare local temporary table tc_table(
    table_id integer not null,
    creator integer not null,
    table_name char(128) not null,
    table_object_id integer not null,
    sysowned char(20) null,) in SYSTEM not transactional;declare local temporary table tc_constraint(
    table_id integer not null,
    constraint_name char(128) not null,
    constraint_type char(11) not null,
    description varchar(254) null,) in SYSTEM not transactional;insert into tc_table
    select t.table_id,t.creator,t.table_name,t.object_id,
      null
      from SYS.SYSTABLE as t join SYS.SYSUSERPERMS as u on(t.creator = u.user_id)
      where u.user_name
       = if inConstraintSchema = '' then u.user_name
      else inConstraintSchema
      endif
      and u.user_name
       = if inTableSchema = '' then
        if inTableName = '' then u.user_name
        else dbo.sa_oledb_getowner('table',inTableName)
        endif
      else inTableSchema
      endif
      and t.table_name
       = if inTableName = '' then t.table_name
      else inTableName
      endif;
  if inConstraintType = '' or inConstraintType = 'PRIMARY KEY' then
    insert into tc_constraint
      select tc.table_id,table_name,'PRIMARY KEY',null
        from tc_table as tc
        where exists
        (select * from SYS.SYSCOLUMN as sc
          where sc.table_id = tc.table_id
          and pkey = 'Y');
    update tc_constraint as tc
      set tc.constraint_name = c.constraint_name from
      tc_constraint as tc join SYS.SYSCONSTRAINT as c on(tc.table_id = c.table_object_id)
      where c.constraint_type = 'P'
      and tc.constraint_type = 'PRIMARY KEY'
      and substr(c.constraint_name,1,3) <> 'ASA'
  end if;
  if inConstraintType = '' or inConstraintType = 'FOREIGN KEY' then
    insert into tc_constraint
      select tc.table_id,role,'FOREIGN KEY',f.remarks
        from tc_table as tc join SYS.SYSFOREIGNKEY as f on(tc.table_id = f.foreign_table_id);
    update tc_constraint as tc
      set tc.constraint_name = c.constraint_name from
      tc_constraint as tc join SYS.SYSCONSTRAINT as c on(tc.table_id = c.table_object_id)
      where c.constraint_type = 'F'
      and tc.constraint_type = 'FOREIGN KEY'
      and substr(c.constraint_name,1,3) <> 'ASA'
  end if;
  if inConstraintType = '' or inConstraintType = 'UNIQUE' then
    insert into tc_constraint
      select tc.table_id,index_name,'UNIQUE',null
        from tc_table as tc join SYS.SYSINDEX as i on(tc.table_id = i.table_id)
        where i."unique" = 'U';
    update tc_constraint as tc
      set tc.constraint_name = c.constraint_name from
      tc_constraint as tc join SYS.SYSCONSTRAINT as c on(tc.table_id = c.table_object_id)
      where c.constraint_type = 'U'
      and tc.constraint_type = 'UNIQUE'
      and substr(c.constraint_name,1,3) <> 'ASA'
  end if;
  if inConstraintType = '' or inConstraintType = 'CHECK' then
    insert into tc_constraint
      select tc.table_id,constraint_name,'CHECK',check_defn
        from tc_table as tc join SYS.SYSCONSTRAINT as c on(tc.table_object_id = c.table_object_id)
          join SYS.SYSCHECK as k on(k.check_id = c.constraint_id)
        where c.constraint_type in( 'C','T' ) 
  end if;
  if(inConstraintCatalog = db_name() or inConstraintCatalog = '')
    and(inTableCatalog = db_name() or inTableCatalog = '') then
    select db_name() as CONSTRAINT_CATALOG,
      u.user_name as CONSTRAINT_SCHEMA,
      c.constraint_name as CONSTRAINT_NAME,
      db_name() as TABLE_CATALOG,
      u.user_name as TABLE_SCHEMA,
      t.table_name as TABLE_NAME,
      c.constraint_type as CONSTRAINT_TYPE,
      0 as IS_DEFERRABLE,
      0 as INITIALLY_DEFFERED,
      c.description as DESCRIPTION
      from tc_table as t
        join tc_constraint as c on(t.table_id = c.table_id)
        join SYS.SYSUSERPERMS as u on(t.creator = u.user_id)
      where c.constraint_name
       = if inConstraintName = '' then c.constraint_name
      else inConstraintName
      endif order by 1 asc,2 asc,3 asc,4 asc,5 asc,6 asc,7 asc
  else
    select null as CONSTRAINT_CATALOG,
      null as CONSTRAINT_SCHEMA,
      null as CONSTRAINT_NAME,
      null as TABLE_CATALOG,
      null as TABLE_SCHEMA,
      null as TABLE_NAME,
      null as CONSTRAINT_TYPE,
      null as IS_DEFERRABLE,
      null as INITIALLY_DEFERRED,
      null as DESCRIPTION
  end if
end
