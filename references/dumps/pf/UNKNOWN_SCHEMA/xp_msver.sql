-- PF: UNKNOWN_SCHEMA.xp_msver
-- proc_id: 53
-- generated_at: 2025-12-29T13:53:28.706Z

create function dbo.xp_msver( 
  in the_option char(254) default 'ProductName' ) 
returns char(254)
begin
  declare r char(254);
  set r
     = case the_option
    when 'ProductName' then
      property('ProductName')
    when 'ProductVersion' then
      property('ProductVersion')
    when 'CompanyName' then
      property('CompanyName')
    when 'LegalCopyright' then
      property('LegalCopyright')
    when 'LegalTrademarks' then
      property('LegalTrademarks')
    when 'FileDescription' then
      property('ProductName') || ' ' || property('Platform')
    else
      '<unknown>'
    end;
  return(r)
end
