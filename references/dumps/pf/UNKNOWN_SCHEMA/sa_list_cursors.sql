-- PF: UNKNOWN_SCHEMA.sa_list_cursors
-- proc_id: 228
-- generated_at: 2025-12-29T13:53:28.758Z

create procedure dbo.sa_list_cursors()
result( 
  handle unsigned integer,
  scope integer,
  cursor_name varchar(128),
  is_open bit,
  is_pinned bit,
  fetch_count unsigned bigint ) dynamic result sets 1
internal name 'sa_list_cursors'
