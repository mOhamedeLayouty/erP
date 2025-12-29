-- PF: UNKNOWN_SCHEMA.sa_user_defined_counter_set
-- proc_id: 252
-- generated_at: 2025-12-29T13:53:28.766Z

create function dbo.sa_user_defined_counter_set( 
  in counter_name varchar(128),
  in value bigint,
  in apply_to_con integer default 1,
  in apply_to_db integer default 0,
  in apply_to_server integer default 0 ) 
returns integer
internal name 'sa_user_defined_counter_set'
