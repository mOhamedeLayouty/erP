-- PF: UNKNOWN_SCHEMA.sa_copy_cursor_to_temp_table
-- proc_id: 227
-- generated_at: 2025-12-29T13:53:28.758Z

create procedure dbo.sa_copy_cursor_to_temp_table( 
  cursor_name varchar(256),
  table_name varchar(256),
  first_row bigint default 1,
  max_rows bigint default 9223372036854775807 ) 
sql security invoker
internal name 'sa_copy_cursor_to_temp_table'
