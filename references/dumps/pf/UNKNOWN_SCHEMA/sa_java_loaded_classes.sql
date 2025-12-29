-- PF: UNKNOWN_SCHEMA.sa_java_loaded_classes
-- proc_id: 165
-- generated_at: 2025-12-29T13:53:28.740Z

create procedure dbo.sa_java_loaded_classes()
result( class_name varchar(512) ) dynamic result sets 1
begin
  declare local temporary table sa_vm_enum_table(
    class_name char(512) null,
    ) in SYSTEM not transactional;
  call dbo.sa_internal_java_loaded_classes();
  select * from sa_vm_enum_table order by class_name asc
end
