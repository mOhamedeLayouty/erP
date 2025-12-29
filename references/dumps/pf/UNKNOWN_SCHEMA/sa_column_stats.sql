-- PF: UNKNOWN_SCHEMA.sa_column_stats
-- proc_id: 249
-- generated_at: 2025-12-29T13:53:28.764Z

create procedure dbo.sa_column_stats( 
  in tab_name char(128) default '%',
  in col_name char(128) default '%',
  in tab_owner char(128) default '%',
  in max_rows integer default 1000 ) 
result( 
  table_owner char(128),
  table_name char(128),
  column_name char(128),
  num_rows_processed integer,
  num_values_compressed integer,
  avg_compression_ratio double,
  avg_length double,
  stddev_length double,
  min_length integer,
  max_length integer,
  avg_uncompressed_length double,
  stddev_uncompressed_length double,
  min_uncompressed_length integer,
  max_uncompressed_length integer ) dynamic result sets 1
begin
  declare local temporary table sa_column_stats(
    table_owner char(128) null,
    table_name char(128) null,
    column_name char(128) null,
    num_rows_processed integer null,
    num_values_compressed integer null,
    avg_compression_ratio double null,
    avg_length double null,
    stddev_length double null,
    min_length integer null,
    max_length integer null,
    avg_uncompressed_length double null,
    stddev_uncompressed_length double null,
    min_uncompressed_length integer null,
    max_uncompressed_length integer null,
    ) in SYSTEM not transactional;
  declare c dynamic scroll cursor for
    select u.user_name,t.table_name,c.column_name
      from SYS.SYSTAB as t
        join SYS.SYSUSER as u on(u.user_id = t.creator)
        join SYS.SYSTABCOL as c on(c.table_id = t.table_id)
      where t.table_type = 1
      and t.server_type = 1
      and u.user_name like tab_owner
      and t.table_name like tab_name
      and c.column_name like col_name
      order by u.user_name asc,t.table_name asc,c.column_name asc;
  declare own varchar(128);
  declare tab varchar(128);
  declare col varchar(128);
  open c;
  l: loop
    fetch next c into own,tab,col;
    if sqlcode <> 0 then leave l end if;
    call sa_int_column_stats(tab,col,own,max_rows)
  end loop l;
  close c;
  select * from sa_column_stats order by table_owner asc,table_name asc,
    column_name asc
end
