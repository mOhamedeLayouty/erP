-- PF: UNKNOWN_SCHEMA.sp_jdbc_class_for_name
-- proc_id: 351
-- generated_at: 2025-12-29T13:53:28.794Z

create procedure dbo.sp_jdbc_class_for_name( 
  in @class_name varchar(255) ) 
result( contents long binary ) dynamic result sets 1
begin
  select comp.contents
    from SYS.SYSJAVACLASS as cls,SYS.SYSJARCOMPONENT as comp
    where cls.class_name = @class_name and cls.component_id = comp.component_id
end
