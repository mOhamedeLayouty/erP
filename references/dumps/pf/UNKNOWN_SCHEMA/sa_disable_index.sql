-- PF: UNKNOWN_SCHEMA.sa_disable_index
-- proc_id: 199
-- generated_at: 2025-12-29T13:53:28.749Z

create procedure dbo.sa_disable_index( 
  in index_name char(128),
  in table_name char(128) default null,
  in creator_name char(128) default null ) 
begin
  call dbo.sa_internal_alter_index_ability(0,index_name,table_name,creator_name)
end
