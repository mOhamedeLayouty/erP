-- PF: UNKNOWN_SCHEMA.sp_dboption
-- proc_id: 10
-- generated_at: 2025-12-29T13:53:28.694Z

create procedure dbo.sp_dboption( 
  in @dbname char(128) default null,
  in @optname char(128) default null,
  in @true_false char(5) default null ) 
begin
  declare setting char(3);
  if @dbname is null or @optname is null or @true_false is null then
    call sp_tsql_feature_not_supported()
  else
    if lcase(@true_false) = 'true' then
      set setting = 'on'
    else
      set setting = 'off'
    end if;
    if 'allow nulls by default' like(lcase(@optname) || '%') then
      execute immediate with quotes on
        'set option ' || current user || '.allow_nulls_by_default = '''
         || setting || ''''
    else
      call sp_tsql_feature_not_supported()
    end if
  end if
end
