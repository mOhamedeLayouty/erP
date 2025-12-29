-- PF: UNKNOWN_SCHEMA.sa_add_index_consultant_analysis
-- proc_id: 209
-- generated_at: 2025-12-29T13:53:28.753Z

create procedure dbo.sa_add_index_consultant_analysis( in master_name char(128) ) 
result( master_id integer ) dynamic result sets 1
begin
  insert into dbo.ix_consultant_master( creator,name,summary ) 
    select user_id,master_name,null
      from SYS.SYSUSER
      where user_name = current user;
  select @@identity
end
