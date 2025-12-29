-- PF: UNKNOWN_SCHEMA.sp_jdbc_stored_procedures
-- proc_id: 342
-- generated_at: 2025-12-29T13:53:28.792Z

create procedure dbo.sp_jdbc_stored_procedures( 
  @sp_qualifier varchar(128)= null,
  @sp_owner varchar(128)= null,
  @sp_name varchar(128)= null,
  @functions integer= 0 ) as
if @sp_owner is null select @sp_owner = '%'
if @sp_name is null select @sp_name = '%'
if @functions = 0
  begin
    select PROCEDURE_CAT=dbo.sp_jconnect_trimit(db_name()),
      PROCEDURE_SCHEM=dbo.sp_jconnect_trimit(user_name(creator)),
      PROCEDURE_NAME=dbo.sp_jconnect_trimit(proc_name),
      num_input_params=(select count() from SYS.SYSPROCPARM as t2
        where t2.proc_id = t1.proc_id and parm_mode_in = 'Y'),
      num_output_params=(select count() from SYS.SYSPROCPARM as t3
        where t3.proc_id = t1.proc_id and parm_mode_out = 'Y'),
      num_result_sets=(select count() from SYS.SYSPROCPARM as t4
        where t4.proc_id = t1.proc_id and parm_type = 1),
      REMARKS=null,
      PROCEDURE_TYPE=(select(if(select max(PARM_TYPE) from SYS.SYSPROCPARM as t5
          where t5.proc_id = t1.proc_id) = 4 then 2 else 1 endif)),
      SPECIFIC_NAME=dbo.sp_jconnect_trimit(proc_name)
      from SYS.SYSPROCEDURE as t1
      where proc_name like @sp_name escape '\\'
      and user_name(creator) like @sp_owner escape '\\'
      order by PROCEDURE_CAT asc,PROCEDURE_SCHEM asc,PROCEDURE_NAME asc,SPECIFIC_NAME asc
  end
else
  begin
    select FUNCTION_CAT=dbo.sp_jconnect_trimit(db_name()),
      FUNCTION_SCHEM=dbo.sp_jconnect_trimit(user_name(creator)),
      FUNCTION_NAME=dbo.sp_jconnect_trimit(proc_name),
      REMARKS=null,
      FUNCTION_TYPE=1,
      SPECIFIC_NAME=dbo.sp_jconnect_trimit(proc_name)
      from SYS.SYSPROCEDURE as t1
      where proc_name like @sp_name escape '\\'
      and user_name(creator) like @sp_owner escape '\\'
      and(select count() from SYSPROCPARM as t2
        where t2.proc_id = t1.proc_id
        and dbo.sp_jconnect_trimit(parm_name) = dbo.sp_jconnect_trimit(proc_name)) <> 0
      order by FUNCTION_CAT asc,FUNCTION_SCHEM asc,FUNCTION_NAME asc,SPECIFIC_NAME asc
  end
