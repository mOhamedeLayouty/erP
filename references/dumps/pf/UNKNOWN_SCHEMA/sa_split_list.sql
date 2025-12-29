-- PF: UNKNOWN_SCHEMA.sa_split_list
-- proc_id: 236
-- generated_at: 2025-12-29T13:53:28.760Z

create procedure dbo.sa_split_list( in str long varchar,in delim char(10) default ',',in maxlen integer default 0 ) 
result( 
  line_num integer,
  row_value long varchar ) dynamic result sets 1
begin
  declare local temporary table sa_split_list(
    line_num integer not null,
    row_value long varchar null,
    primary key(line_num),) in SYSTEM not transactional;
  call dbo.sa_internal_split_list(str,delim,maxlen);
  select * from sa_split_list order by line_num asc
end
