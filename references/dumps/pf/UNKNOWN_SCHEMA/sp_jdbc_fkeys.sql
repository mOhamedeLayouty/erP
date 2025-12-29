-- PF: UNKNOWN_SCHEMA.sp_jdbc_fkeys
-- proc_id: 333
-- generated_at: 2025-12-29T13:53:28.789Z

create procedure dbo.sp_jdbc_fkeys( 
  @pktable_name varchar(128),
  @pktable_owner varchar(128),
  @pktable_qualifier varchar(128),
  @fktable_name varchar(128),
  @fktable_owner varchar(128),
  @fktable_qualifier varchar(128) ) as
delete from dbo.jdbc_helpkeys
insert into dbo.jdbc_helpkeys( PKTABLE_CAT,PKTABLE_SCHEM,PKTABLE_NAME,
  PKCOLUMN_NAME,FKTABLE_CAT,FKTABLE_SCHEM,FKTABLE_NAME,FKCOLUMN_NAME,
  KEY_SEQ,UPDATE_RULE,DELETE_RULE,FK_NAME,PK_NAME,DEFERRABILITY ) 
  select PKTABLE_CAT=db_name(),
    PKTABLE_SCHEM=user_name(PKT.creator),
    PKTABLE_NAME=PKT.table_name,
    PKCOLUMN_NAME=PKCOL.column_name,
    FKTABLE_CAT=db_name(),
    FKTABLE_SCHEM=user_name(FKT.creator),
    FKTABLE_NAME=FKT.table_name,
    FKCOLUMN_NAME=FKCOL.column_name,
    KEY_SEQ=(select count() from SYS.SYSFKCOL as other
      where foreign_table_id = FK.foreign_table_id
      and foreign_key_id = FK.foreign_key_id
      and primary_column_id <= COL.primary_column_id),
    UPDATE_RULE=COALESCE((select(if referential_action = 'C' then 0
      else if referential_action = 'N' then 2
        else if referential_action = 'D' then 4
          else 3
          endif
        endif
      endif) from SYS.SYSTRIGGER as TRG
      where FK.foreign_table_id = TRG.foreign_table_id
      and FK.foreign_key_id = TRG.foreign_key_id
      and event in( 'C','U' ) ),
    1),
    DELETE_RULE=COALESCE((select(if referential_action = 'C' then 0
      else if referential_action = 'N' then 2
        else if referential_action = 'D' then 4
          else 3
          endif
        endif
      endif) from SYS.SYSTRIGGER as TRG
      where FK.foreign_table_id = TRG.foreign_table_id
      and FK.foreign_key_id = TRG.foreign_key_id
      and event = 'D'),
    1),
    FK_NAME=FK.role,
    PK_NAME=null,
    DEFERRABILITY=7
    from SYS.SYSFOREIGNKEY as FK
      join SYS.SYSTABLE as PKT on FK.primary_table_id = PKT.table_id
      join SYS.SYSTABLE as FKT on FK.foreign_table_id = FKT.table_id
      join SYS.SYSFKCOL as COL on FK.foreign_table_id = COL.foreign_table_id
      and FK.foreign_key_id = COL.foreign_key_id
      join SYS.SYSCOLUMN as PKCOL on FK.primary_table_id = PKCOL.table_id
      and COL.primary_column_id = PKCOL.column_id
      join SYS.SYSCOLUMN as FKCOL on FK.foreign_table_id = FKCOL.table_id
      and COL.foreign_column_id = FKCOL.column_id
    where(@pktable_owner is null or PKTABLE_SCHEM like @pktable_owner escape '\\')
    and(@pktable_name is null or PKTABLE_NAME like @pktable_name escape '\\')
    and(@fktable_owner is null or FKTABLE_SCHEM like @fktable_owner escape '\\')
    and(@fktable_name is null or FKTABLE_NAME like @fktable_name escape '\\')
