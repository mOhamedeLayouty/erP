-- PF: UNKNOWN_SCHEMA.sa_enable_index
-- proc_id: 198
-- generated_at: 2025-12-29T13:53:28.749Z

create procedure dbo.sa_enable_index( 
  in index_name char(128),
  in table_name char(128) default null,
  in creator_name char(128) default null ) 
begin
  call dbo.sa_internal_alter_index_ability(1,index_name,table_name,creator_name)
end
