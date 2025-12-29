-- PF: UNKNOWN_SCHEMA.sa_http_header_info
-- proc_id: 216
-- generated_at: 2025-12-29T13:53:28.755Z

create procedure dbo.sa_http_header_info( in header_parm varchar(255) default null ) 
result( 
  Name varchar(255),
  Value long varchar ) dynamic result sets 1
begin
  declare header_name varchar(255);
  declare local temporary table t_http_header_info(
    Name varchar(255) not null,
    Value long varchar null,
    ) in SYSTEM not transactional;
  if(header_parm is not null) then
    insert into t_http_header_info values
      ( header_parm,http_header(header_parm) ) 
  else
    set header_name = next_http_header(null);
    while header_name is not null loop
      insert into t_http_header_info values
        ( header_name,http_header(header_name) ) ;
      set header_name = next_http_header(header_name)
    end loop
  end if;
  select * from t_http_header_info
end
