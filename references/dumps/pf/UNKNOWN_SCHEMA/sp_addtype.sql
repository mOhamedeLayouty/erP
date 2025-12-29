-- PF: UNKNOWN_SCHEMA.sp_addtype
-- proc_id: 7
-- generated_at: 2025-12-29T13:53:28.692Z

create procedure dbo.sp_addtype( 
  in @typename char(128),
  in @phystype char(30),
  in @ident_null char(20) default 'not specified' ) 
begin
  declare dflt char(30);
  declare nullable char(8);
  call dbo.sp_checkperms('RESOURCE');
  set dflt = '';
  set nullable = '';
  if @ident_null is null then
    set @ident_null = 'null'
  end if;
  if @ident_null <> 'not specified' then
    if lcase(@ident_null) = 'identity' then
      set dflt = 'default autoincrement';
      set nullable = 'not null'
    else
      if lcase(@ident_null) = 'nonull' then
        set nullable = 'not null'
      else
        set nullable = @ident_null
      end if
    end if
  end if;
  execute immediate with quotes on
    'create domain ' || @typename || ' '
     || @phystype || ' ' || nullable || ' ' || dflt
end
