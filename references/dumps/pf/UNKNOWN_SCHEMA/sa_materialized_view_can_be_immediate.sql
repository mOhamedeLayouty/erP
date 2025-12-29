-- PF: UNKNOWN_SCHEMA.sa_materialized_view_can_be_immediate
-- proc_id: 223
-- generated_at: 2025-12-29T13:53:28.757Z

create procedure dbo.sa_materialized_view_can_be_immediate( 
  in view_name char(128),
  in owner_name char(128) ) 
result( 
  SQLStateVal char(6),
  ErrorMessage long varchar ) dynamic result sets 1
begin
  declare local temporary table iMVErrorMessages(
    SQLStateVal char(6) null,
    ErrorMessage long varchar null,
    ) in SYSTEM not transactional;
  call dbo.sa_internal_materialized_view_can_be_immediate(view_name,owner_name);
  select *
    from iMVErrorMessages
end
