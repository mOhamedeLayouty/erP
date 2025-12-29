-- PF: UNKNOWN_SCHEMA.sp_fkeys
-- proc_id: 21
-- generated_at: 2025-12-29T13:53:28.697Z

create procedure dbo.sp_fkeys( 
  in @pktable_name char(1024) default null,
  in @pktable_owner char(1024) default null,
  in @pktable_qualifier char(1024) default null,
  in @fktable_name char(1024) default null,
  in @fktable_owner char(1024) default null,
  in @fktable_qualifier char(1024) default null ) 
result( 
  pktable_qualifier char(128),
  pktable_owner char(128),
  pktable_name char(128),
  pkcolumn_name char(128),
  fktable_qualifier char(128),
  fktable_owner char(128),
  fktable_name char(128),
  fkcolumn_name char(128),
  key_seq unsigned integer,
  update_rule smallint,
  delete_rule smallint ) dynamic result sets 1
begin
  if @pktable_name is null and @fktable_name is null then
    return
  end if;
  if @pktable_name is null then
    set @pktable_name = '%'
  end if;
  if @pktable_owner is null then
    set @pktable_owner = '%'
  end if;
  if @fktable_name is null then
    set @fktable_name = '%'
  end if;
  if @fktable_owner is null then
    set @fktable_owner = '%'
  end if;
  select current database,
    po.user_name,
    pt.table_name,
    ptc.column_name,
    current database,
    fo.user_name,
    ft.table_name,
    ftc.column_name,
    fkc.primary_column_id,
    0,
    0
    from SYS.SYSFOREIGNKEY as fk,SYS.SYSFKCOL as fkc
      ,SYS.SYSTAB as pt,SYS.SYSTABCOL as ptc,SYS.SYSUSER as po
      ,SYS.SYSTAB as ft,SYS.SYSTABCOL as ftc,SYS.SYSUSER as fo
    where fk.primary_table_id = pt.table_id
    and pt.table_id = ptc.table_id
    and ptc.column_id = fkc.primary_column_id
    and pt.creator = po.user_id
    and fk.foreign_table_id = ft.table_id
    and ft.table_id = ftc.table_id
    and ftc.column_id = fkc.foreign_column_id
    and ft.creator = fo.user_id
    and fk.foreign_table_id = fkc.foreign_table_id
    and fk.foreign_key_id = fkc.foreign_key_id
    and ft.table_name like @fktable_name
    and fo.user_name like @fktable_owner
    and pt.table_name like @pktable_name
    and po.user_name like @pktable_owner
    order by ft.table_name asc,fo.user_name asc,fkc.primary_column_id asc
end
