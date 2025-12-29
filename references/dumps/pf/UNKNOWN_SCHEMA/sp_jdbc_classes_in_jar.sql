-- PF: UNKNOWN_SCHEMA.sp_jdbc_classes_in_jar
-- proc_id: 352
-- generated_at: 2025-12-29T13:53:28.794Z

create procedure dbo.sp_jdbc_classes_in_jar( 
  in @jar_name varchar(255) ) 
result( class_name long varchar ) dynamic result sets 1
begin
  select sjc.class_name
    from SYS.SYSJAVACLASS as sjc,SYS.SYSJAR as sj
    where sj.jar_name = @jar_name and sj.jar_id = sjc.jar_id
end
