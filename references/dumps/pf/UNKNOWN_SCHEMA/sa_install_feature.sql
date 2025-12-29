-- PF: UNKNOWN_SCHEMA.sa_install_feature
-- proc_id: 258
-- generated_at: 2025-12-29T13:53:28.768Z

create procedure dbo.sa_install_feature( 
  in feat_name long varchar default null ) 
begin
  if feat_name = 'st_geometry_predefined_uom' then
    for uom as curs1 dynamic scroll cursor for
      select unit_name,ddl,ddl_comment
        from dbo.st_geometry_predefined_uom('CREATE IF NOT EXISTS') as PUOM
        where not exists(select * from sys.sysunitofmeasure as uom where PUOM.unit_name = uom.unit_name)
        and ddl is not null
    do
      execute immediate with quotes on ddl
    end for
  elseif feat_name = 'st_geometry_predefined_srs' then
    call dbo.sa_install_feature('st_geometry_predefined_uom');
    for srs as curs2 dynamic scroll cursor for
      select srs_name,ddl,ddl_comment
        from dbo.st_geometry_predefined_srs('CREATE IF NOT EXISTS') as PSRS
        where not exists(select * from sys.sysspatialreferencesystem as srs where PSRS.srs_name = srs.srs_name)
        and ddl is not null
    do
      execute immediate with quotes on ddl
    end for
  elseif feat_name = 'st_geometry_compat_func' then
    call dbo.sa_exec_script('st_geometry_compat_func.sql')
  else
    raiserror 20005 'Invalid feature name ''' || feat_name || ''' specified'
  end if
end
