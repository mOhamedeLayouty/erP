-- PF: UNKNOWN_SCHEMA.sp_serverinfo
-- proc_id: 23
-- generated_at: 2025-12-29T13:53:28.697Z

create procedure dbo.sp_serverinfo( in @request varchar(30) default null ) 
result( collation_name varchar(1024) ) dynamic result sets 1
begin
  if @request = 'server_soname' then
    if db_property('CaseSensitive') = 'Off' then
      select DB_EXTENDED_PROPERTY('Collation','ASEInsensitiveSortOrder')
    else
      select DB_EXTENDED_PROPERTY('Collation','ASESensitiveSortOrder')
    end if
  elseif @request = 'server_csname' then
    select DB_PROPERTY('Charset')
  end if
end
