-- PF: UNKNOWN_SCHEMA.sa_internal_alter_index_ability
-- proc_id: 197
-- generated_at: 2025-12-29T13:53:28.749Z

create procedure dbo.sa_internal_alter_index_ability( 
  in able integer,
  in index_name char(128),
  in table_name char(128),
  in creator_name char(128) ) 
internal name alter_index_ability
