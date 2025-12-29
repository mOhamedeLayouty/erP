-- PF: UNKNOWN_SCHEMA.sa_user_defined_counter_add
-- proc_id: 251
-- generated_at: 2025-12-29T13:53:28.766Z

create function dbo.sa_user_defined_counter_add( 
  in counter_name varchar(128),
  in delta bigint default 1,
  in apply_to_con integer default 1,
  in apply_to_db integer default 1,
  in apply_to_server integer default 1 ) 
returns integer
internal name 'sa_user_defined_counter_add'
