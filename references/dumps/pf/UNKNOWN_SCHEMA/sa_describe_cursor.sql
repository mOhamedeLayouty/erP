-- PF: UNKNOWN_SCHEMA.sa_describe_cursor
-- proc_id: 226
-- generated_at: 2025-12-29T13:53:28.758Z

create procedure dbo.sa_describe_cursor( 
  in cursor_name varchar(256) ) 
result( 
  column_number integer,
  name varchar(128),
  domain_id smallint,
  domain_name varchar(128),
  domain_name_with_size varchar(160),
  width integer,
  scale integer,
  declared_width integer,
  user_type_id smallint,
  user_type_name varchar(128),
  correlation_name varchar(128),
  base_table_id unsigned integer,
  base_column_id unsigned integer,
  base_owner_name varchar(128),
  base_table_name varchar(128),
  base_column_name varchar(128),
  nulls_allowed bit,
  is_autoincrement bit,
  is_key_column bit,
  is_added_key_column bit ) dynamic result sets 1
internal name 'sa_describe_cursor'
